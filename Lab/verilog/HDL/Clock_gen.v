`timescale 1ns/100ps

module Clock_gen(
	input sys_rst_n,
	input clk50_src,
	output clk200,
	output clk100,
	output clk50,
	output rst_n
);

	reg [7:0] clk_cnt;
	wire pll_rdy;
	wire clk400;

	PLL PLL (
	.areset(~sys_rst_n),
	.inclk0(clk50_src),
	.c0(clk200),
	.c1(clk400),
	.locked(pll_rdy)
	);
	
	
	always @(negedge clk200 or negedge rst_n) begin
		if (rst_n == 0)
			clk_cnt <= 8'b0;
		else
			clk_cnt <= clk_cnt + 1;
	end

	
	assign clk100 =clk_cnt[0];
	assign clk50 = clk_cnt[1];

	assign rst_n = pll_rdy;


endmodule
