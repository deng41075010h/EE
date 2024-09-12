`timescale 1ns/100ps

module Main_Top (
	input clk50_src,
	input sys_rst_n,
	input [31:0] L_data,
	input [31:0] A_data,
	input [31:0] B_data,
	input pixel_clk,
	input [11:0] Pixel_Col_cnt,
	input [11:0] Pixel_Row_cnt,
	output rst_n,
	output clk50,
	output [7:0] RM_data,
	output [7:0] GM_data,
	output [7:0] BM_data,
	output rst2_n
);

	wire [31:0] L_bin, A_bin, B_bin;
	wire [31:0] LE_data, AE_data, BE_data, BC_data, GC_data, RC_data;
	wire [7:0] R_level, G_level, B_level;

	wire [11:0] Pixel_Col;	// (1448)_10
	wire [11:0] Pixel_Row;	// (1072)_10


	assign Pixel_Col = Pixel_Col_cnt;
	assign Pixel_Row = Pixel_Row_cnt;
	
	Clock_gen Clk_gen(
		.sys_rst_n(sys_rst_n),	  // input
		.clk50_src(clk50_src),	  // input
		.clk200(clk200),	        // output
		.clk100(clk100),	        // output
		.clk50(clk50),	           // output
		.rst_n(rst_n)	           // output
	);

	Float2fix float2fix(
		.rst_n(rst2_n),   // input
		.clk(pixel_clk),  // input
		.L_fp(L_data),    // input [31:0] 
		.A_fp(A_data),    // input [31:0] 
		.B_fp(B_data),    // input [31:0] 
		.L_bin(L_bin),    // output [31:0] 
		.A_bin(A_bin),    // output [31:0] 
		.B_bin(B_bin)     // output [31:0] 
	);
	
	Color_Enhance Color_Enhance(
		.rst_n(rst2_n),      // input
		.clk(pixel_clk),     // input
		.L_data(L_bin),	   // input [31:0]
		.A_data(A_bin),	   // input [31:0]
		.B_data(B_bin),	   // input [31:0]
		.LE_data(LE_data),	// output [31:0]
		.AE_data(AE_data),	// output [31:0]
		.BE_data(BE_data)	   // output [31:0]
	);

	Lab2rgb Lab2rgb(
		.rst_n(rst2_n),	   // input
		.clk(pixel_clk),     // input
		.LE_data(LE_data),	// input [31:0]
		.AE_data(AE_data),	// input [31:0]
		.BE_data(BE_data),	// input [31:0]
		.BC_data(BC_data),	// output [31:0]
		.GC_data(GC_data),	// output [31:0]
		.RC_data(RC_data)	   // output [31:0]
	);

	
	HalfTone_Top HalfTone_Top (
		.rst_n(rst_n), // input
		.clk200(clk200), // input
		.pixel_clk(pixel_clk), // input
		.Pixel_Col(Pixel_Col), // input [11:0]
		.Pixel_Row(Pixel_Row), // input [11:0]
		.BC_data(BC_data),	// input [31:0] RGB
		.GC_data(GC_data),	// input [31:0] RGB
		.RC_data(RC_data),	// input [31:0] RGB
		.B_level(B_level), // output [7:0] level
		.G_level(G_level), // output [7:0] level
		.R_level(R_level), // output [7:0] level
		.osram_rst_n(rst2_n) // output
	);
	
	
	CFAmapping cfa(
		.rst_n(rst2_n),   // input
		.clk(pixel_clk),  // input pixel_clk
		.R(R_level),      // input [7:0]
		.G(G_level),      // input [7:0]
		.B(B_level),      // input [7:0]
		.cfa_R(RM_data),  // output [7:0]
		.cfa_G(GM_data),  // output [7:0]
		.cfa_B(BM_data)   // output [7:0]
	);

endmodule
