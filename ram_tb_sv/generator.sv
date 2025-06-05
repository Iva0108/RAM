class generator;

	mailbox #(transaction) gen2drv, gen2sco; // one mailbox is for the driver, second one is for the scoreboard to form golden data
	int count; // number of times to generate stimuli (change in tb_top file)
	transaction tr; // local transaction object
	event scoreboard_done, generator_done;

	function new(mailbox #(transaction) gen2drv, gen2sco, int count, event scoreboard_done, generator_done);
		this.gen2drv = gen2drv;
		this.count = count;
		this.scoreboard_done = scoreboard_done;
		this.generator_done = generator_done;
		this.gen2sco = gen2sco;
	endfunction

	function void display_op(); // function to display which operation is to be performed on DUT with time in nanoseconds
		if(tr.wr_rd == 1 && tr.en == 1) 
			$display("[GEN] : WRITE OPERATION \t DIN : %0d \t | \t TIME : %0t", tr.din, $time);
		else if(tr.wr_rd == 0 && tr.en == 1)
			$display("[GEN] : READ OPERATION \t | \t TIME : %0t", $time);
		else
			$display("[GEN] : NO ENABLE! \t | \t TIME : %0t", $time);
	endfunction

	task run();
		tr = new(); // create one transacion object and use it for the whole time of the simulation in generator process
		repeat(count) begin // generate stimuli for 'count' number of times
			assert(tr.randomize) else begin
				$display("[GEN] : RANDOMIZATION FAILED! \t | \t TIME : %0t", $time); // if the randomization has failed display appropriate message
			end
			display_op();
			gen2drv.put(tr.copy); // send a deep copy to driver
			gen2sco.put(tr.copy); // send a deep copy to scoreboard for golden data forming
			@(scoreboard_done);
		end
		-> generator_done; // trigger an event to end the simulation        
	endtask

endclass