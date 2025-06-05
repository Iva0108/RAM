class scoreboard;

	mailbox #(transaction) mon2sco, gen2sco;
	event scoreboard_done;

	transaction tr, tr_ref; // additional local transaction object for the golden data forming

	bit [7:0] temp[0:15]; // golden data for din
	int error_count = 0; // counts the times when actual data and golden data don't match

	function new(mailbox #(transaction) mon2sco, gen2sco, event scoreboard_done);
		this.mon2sco = mon2sco;   
		this.gen2sco = gen2sco;
		this.scoreboard_done = scoreboard_done;
	endfunction
	
	function void initialize_temp();
		for(int i = 0; i < 16; i++) begin
			temp[i] = 0;
		end
	endfunction

	task temp_update;
		if(tr_ref.wr_rd == 1 && tr_ref.en == 1) begin
			temp[tr_ref.addr] = tr_ref.din;
		end   
	endtask

	task compare; // actual data and golden data comparison
		if(tr_ref.wr_rd == 0 && tr_ref.en == 1) begin
			if(tr.dout == temp[tr_ref.addr]) begin
				$display("[SCO] : DATA MATCH! \t | \t TIME : %0t", $time); 
			end
			else begin
				$display("[SCO] : DATA MISMATCH! \t | \t TIME : %0t", $time); 
			end
		end
	endtask

	task display_error_count;
		$display("[SCO] : CURRENT ERROR COUNT = %0d \t | \t TIME : %0t", error_count, $time);
		$display("-----------------------------------------------------");
	endtask

	task run;
		initialize_temp();
		forever begin
			gen2sco.get(tr_ref);
			mon2sco.get(tr);
			temp_update();
			compare();
			display_error_count();
			-> scoreboard_done;
		end    
	endtask

endclass