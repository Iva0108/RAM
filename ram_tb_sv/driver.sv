class driver;

	virtual ram_if drv_if; // interface handle (classes can't have interface instances (hardware component) so they use a handle/pointer!)

	mailbox #(transaction) gen2drv; // mailbox to receive data from the generator
	transaction tr; // local transaction object

	function new(mailbox #(transaction) gen2drv, virtual ram_if drv_if);
		this.gen2drv = gen2drv;
		this.drv_if = drv_if; // connect the driver to the interface
	endfunction
	
	function void display_op(); // function to display which operation is to be performed on DUT with time in nanoseconds
		if(tr.wr_rd == 1 && tr.en == 1) 
			$display("[DRV] : PERFORMING WRITE OPERATION \t DIN : %0d \t | \t TIME : %0t", tr.din, $time);
		else if(tr.wr_rd == 0 && tr.en == 1)
			$display("[DRV] : PERFORMING READ OPERATION \t | \t TIME : %0t", $time);
		else
			$display("[DRV] : NO ENABLE! \t | \t TIME : %0t", $time);
	endfunction

	task run();
		forever begin
			gen2drv.get(tr); // get the data from the generator and store it in the local transaction object, no need for a constructor for the transaction object
			display_op();
			// send generator data to the interface ports
			drv_if.din <= tr.din; // always use NON BLOCKING!!
			drv_if.addr <= tr.addr;
			drv_if.wr_rd <= tr.wr_rd;
			drv_if.en <= tr.en;
			@(negedge drv_if.clk); // only send data to interface on the negative edge of the clock
		end 
	endtask

endclass