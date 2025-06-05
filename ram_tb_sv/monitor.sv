class monitor;

	virtual ram_if mon_if;
	mailbox #(transaction) mon2sco;
	transaction tr;

	function new(mailbox #(transaction) mon2sco, virtual ram_if mon_if);
		this.mon2sco = mon2sco;
		this.mon_if = mon_if; // connect monitor to the interface
	endfunction

	task run();
		tr = new(); // create one transaction object to be used for all of the simulation time in the monitor process
		forever begin
			@(posedge mon_if.clk); // only sample data from the interface after the positive edge of the clock
			#2.5; // additional delay, since expected clock period is 10ns, this might not work for higher frequencies
			// store data from the interface in the local transaction object
			tr.din = mon_if.din; 
			tr.dout = mon_if.dout;
			tr.wr_rd = mon_if.wr_rd;
			tr.addr = mon_if.addr;
			tr.en = mon_if.en;
			mon2sco.put(tr); // put the data in a mailbox to be sent to the scoreboard
			$display("[MON] : DIN : %0d \t DOUT : %0d \t WR_RD : %0d \t ADDR : %0d \t EN : %0d \t | \t TIME : %0t", tr.din, tr.dout, tr.wr_rd, tr.addr, tr.en, $time);
		end
	endtask

endclass