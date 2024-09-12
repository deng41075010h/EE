module Comparator(
	input signed [31:0] a,
	input signed [31:0] b,
	output q
);
	// greater
	assign q = (a > b == 1) ? 1'b1 : 0; 

endmodule
