`timescale 1ns/100ps

module Sean_TB ();

	reg sclk50, sys_rst_n;
	wire rst_n;
	wire [31:0] L_data, A_data, B_data;
	wire pixel_clk;
	wire [11:0] Pixel_Col, Pixel_Row;
	wire clk50;
	wire [7:0] RM_data, GM_data, BM_data;

	
	
	Main_Top Main_Top(
		.clk50_src(sclk50),	      // input
		.sys_rst_n(sys_rst_n),	      // input
		.L_data(L_data),              // input [31:0]
		.A_data(A_data),              // input [31:0]
		.B_data(B_data),              // input [31:0]
		.pixel_clk(pixel_clk),	      // intput
		.Pixel_Col_cnt(Pixel_Col),    // input [11:0]
		.Pixel_Row_cnt(Pixel_Row),    // input [11:0]
		.rst_n(rst_n),                // output
		.clk50(clk50),                // output
		.RM_data(RM_data),            // output [7:0] 
		.GM_data(GM_data),            // output [7:0] 
		.BM_data(BM_data),            // output [7:0] 
		.rst2_n(rst2_n)               // output
	);
	
	Pixel_memory Pixel_mem(
		.rst_n(rst2_n),               // input
		.clk50(clk50),                // input
		.L_data(L_data),	      // output [31:0]
		.A_data(A_data),	      // output [31:0]
		.B_data(B_data),	      // output [31:0]
		.pixel_clk(pixel_clk),	      // output
		.Pixel_Col_cnt(Pixel_Col),    // output [11:0]
		.Pixel_Row_cnt(Pixel_Row),    // output [11:0]
		.RM_data(RM_data),            // input [7:0] 
		.GM_data(GM_data),            // input [7:0] 
		.BM_data(BM_data)             // input [7:0] 
	);
	
	always
		begin
			#10 sclk50 = ~sclk50;
		end
		
	initial
		begin
		#0
			sys_rst_n = 0;
			sclk50 <= 0;
		#20
			sys_rst_n = 1;
		#80
			$stop;
			
		// `simulation_time
		
		#40000 // (20ns / 1 pixel)
			$stop;
			$finish;
		end
		
endmodule
