`timescale 1ns/100ps

module HalfTone_Top (
	input rst_n, // rst_n
	input clk200,
	input pixel_clk,
	input [11:0] Pixel_Col,
	input [11:0] Pixel_Row,
	input [31:0] BC_data,	// RGB
	input [31:0] GC_data,	// RGB
	input [31:0] RC_data,	// RGB
	output [7:0] B_level, // level
	output [7:0] G_level, // level
	output [7:0] R_level, // level
	output osram_rst_n // rst2_n
);

	wire rst2_n;
	
	wire [10:0] HT_B_SRAM_ADDR, HT_G_SRAM_ADDR, HT_R_SRAM_ADDR;
	wire [15:0] HT_B_SRAM_D, HT_G_SRAM_D, HT_R_SRAM_D;
	wire [15:0] HT_B_SRAM_Q, HT_G_SRAM_Q, HT_R_SRAM_Q;
	
	Halftone Halftone(
		.rst_n(rst2_n),	      // input
		.clk200(clk200),	      // input
		.pixel_clk(pixel_clk),  // input
		.Pixel_Col(Pixel_Col),	// input [11:0]
		.Pixel_Row(Pixel_Row),	// input [11:0]
		.BC_data(BC_data),	   // input [31:0]
		.GC_data(GC_data),	   // input [31:0]
		.RC_data(RC_data),	   // input [31:0]
		.B_level(B_level),      // output [7:0] CFA mapping
		.G_level(G_level),      // output [7:0] CFA mapping
		.R_level(R_level),      // output [7:0] CFA mapping
		.HT_B_SRAM_ADDR(HT_B_SRAM_ADDR),
		.HT_G_SRAM_ADDR(HT_G_SRAM_ADDR),
		.HT_R_SRAM_ADDR(HT_R_SRAM_ADDR),
		.HT_B_SRAM_D_OUT(HT_B_SRAM_D),
		.HT_G_SRAM_D_OUT(HT_G_SRAM_D),
		.HT_R_SRAM_D_OUT(HT_R_SRAM_D),
		.ht_sram_b_wren(ht_sram_b_wren),
		.ht_sram_g_wren(ht_sram_g_wren),
		.ht_sram_r_wren(ht_sram_r_wren),
		.HT_B_SRAM_QI(HT_B_SRAM_Q),
		.HT_G_SRAM_QI(HT_G_SRAM_Q),
		.HT_R_SRAM_QI(HT_R_SRAM_Q)
	);

	HT_SRAM HT_SRAM(
		.rst_n(rst_n),
		.clk(clk200),
		.HT_B_SRAM_ADDR(HT_B_SRAM_ADDR),
		.HT_G_SRAM_ADDR(HT_G_SRAM_ADDR),
		.HT_R_SRAM_ADDR(HT_R_SRAM_ADDR),
		.HT_B_SRAM_D_IN(HT_B_SRAM_D),
		.HT_G_SRAM_D_IN(HT_G_SRAM_D),
		.HT_R_SRAM_D_IN(HT_R_SRAM_D),
		.ht_sram_b_wren(ht_sram_b_wren),
		.ht_sram_g_wren(ht_sram_g_wren),
		.ht_sram_r_wren(ht_sram_r_wren),
		.HT_B_SRAM_Q(HT_B_SRAM_Q),
		.HT_G_SRAM_Q(HT_G_SRAM_Q),
		.HT_R_SRAM_Q(HT_R_SRAM_Q),
		.osram_rst_n(rst2_n)
	);
	
	assign osram_rst_n = rst2_n;


endmodule
