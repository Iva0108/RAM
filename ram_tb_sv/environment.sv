class environment;

	generator gen;
	driver drv;
	monitor mon;
	scoreboard sco;

	mailbox #(transaction) gen2drv, gen2sco, mon2sco;

	event scoreboard_done, generator_done;

	function new(int count, virtual ram_if env_if);

		// create mailbox objects
		gen2drv = new();
		gen2sco = new();
		mon2sco = new();

		gen = new(gen2drv, gen2sco, count, scoreboard_done, generator_done);
		drv = new(gen2drv, env_if);
		mon = new(mon2sco, env_if);
		sco = new(mon2sco, gen2sco, scoreboard_done);

	endfunction

	task test;
		fork
			gen.run();
			drv.run();
			mon.run();
			sco.run();
		join_none // all of the processes after this line will be executed in parallel with all of the processes in this block    
	endtask

	task post_test;
		@(generator_done);
		$finish; // finish the simulation when generator has generated stimuli for number of times the user set it to
	endtask

	task run;
		test();
		post_test();
	endtask

endclass