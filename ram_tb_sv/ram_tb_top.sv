`include "ram_if.sv"
`include "ram_pkg.sv"

`timescale 1ns / 1ps

import ram_pkg::*;

module ram_tb_top;

	int ram_iterations = 50; // number of times for generator to generate stimuli

	environment env;

	ram_if tb_if(); // interface instance 

	ram dut(.clk(tb_if.clk),
			.din(tb_if.din),
			.dout(tb_if.dout),
			.wr_rd(tb_if.wr_rd),
			.addr(tb_if.addr),
			.en(tb_if.en),
			.rst(tb_if.rst));

	task reset(); // pretest situation, rst is set for 5 positive edges of a clock, and then it is reset
		tb_if.rst <= 1;
		repeat(5) @(posedge tb_if.clk);
		tb_if.rst <= 0;
		@(posedge tb_if.clk); // after non blocking assignment to rst add some delay
	endtask

	initial begin
		env = new(ram_iterations, tb_if); // create environment object and connect it to interface
	end

	initial begin // clock driving
		tb_if.clk <= 0;
	end
	always #5 tb_if.clk = ~tb_if.clk;

	initial begin
		reset();
		env.run();
	end

	initial begin
		$dumpfile("dump.vcd"); // value change dump file
		$dumpvars;
	end

endmodule