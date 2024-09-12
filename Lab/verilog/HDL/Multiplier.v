module Multiplier (
	input signed [31:0] a,
	input signed [31:0] b,
	output signed [31:0] q
);

	wire [63:0] temp = a * b;
	assign q = temp[54:23];

endmodule
