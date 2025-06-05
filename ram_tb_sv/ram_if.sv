interface ram_if(); // ram interface, clk and rst signals are generated in 'tb' module

	logic clk;
	logic rst;
    logic [7:0] din;
    logic [3:0] addr;
    logic wr_rd;
    logic en;
    logic [7:0] dout;

endinterface