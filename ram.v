module ram (
    input rst,
    input clk,
    input [7:0] din, // register with input data
    input [3:0] addr, // address register
    input wr_rd, // write or read, 1 - write, 0 - read
    input en,
    output [7:0] dout 
);

    // Memory declaration
    reg [7:0] memory [0:15]; // reg [7:0] is the type, the rest is an array and its size is 16
    reg [7:0] dout_reg;
	integer i = 0;

    assign dout = (wr_rd == 1'b0 && en == 1'b1) ? dout_reg : 8'bzzzz_zzzz; // if read and enable are active forward data to output reg, if not forward 8 times high z

    always @(posedge clk or posedge rst) begin
        if (rst) begin  //asynchronous reset
            for (i = 0; i < 15; i = i + 1) begin
                memory[i] <= 8'd0;
            end
        end 
		else if (en) begin
            if (wr_rd) begin //writing
                memory[addr] <= din;
            end
			else begin // reading
                dout_reg <= memory[addr];
            end
        end
    end

endmodule
