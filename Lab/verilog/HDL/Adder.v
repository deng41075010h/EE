module Adder (
	input [31:0] a,
	input [31:0] b,
	output [31:0] q
);

	wire [31:0] temp;
	assign temp = a + b;
	// h7f800000 => 255
	assign q = ((a[31] == 0 && b[31] == 0) && temp[31] == 1) ? 32'h7f800000 : temp;

endmodule
