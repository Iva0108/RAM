class transaction;
	
	rand bit [7:0] din;
    rand bit [3:0] addr;
    rand bit wr_rd;
    rand bit en;
    bit [7:0] dout;

	constraint wr_rd_c {wr_rd dist {0 :/ 20, 1 :/ 80};} // write operation happens 80% of the time
	constraint en_c {en dist {0 :/ 10, 1 :/ 90};} // 90% of the time enable is high

	function transaction copy(); // deep copy of the transaction class, which is sent in each of the generator iterations
		copy = new();
		copy.din = this.din;
		copy.addr = this.addr;
		copy.wr_rd = this.wr_rd;
		copy.en = this.en;
		copy.dout = this.dout;
	endfunction

endclass