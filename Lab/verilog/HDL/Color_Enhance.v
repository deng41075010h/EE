`timescale 1ns/100ps

module Color_Enhance(
	input rst_n, // rst2_n
	input clk,   // pixel_clk
	input [31:0] L_data,	
	input [31:0] A_data,
	input [31:0] B_data,
	output [31:0] LE_data,
	output [31:0] AE_data,
	output [31:0] BE_data
);
	
	// 1 bit sign, 8 bit int, 23 bit fraction
	wire [31:0] const_1_dot_5 = 32'b00000000110000000000000000000000; // 1.5


	Multiplier mul_a(
		.a(A_data),         // input [31:0] 
		.b(const_1_dot_5),  // input [31:0] 
		.q(AE_data)         // output [31:0] 
	);
	Multiplier mul_b(
		.a(B_data),         // input [31:0] 
		.b(const_1_dot_5),  // input [31:0] 
		.q(BE_data)         // output [31:0] 
	);
	
	assign LE_data = L_data;
	
	// debug process
	// synthesis translate_off
	
	/*
	integer f_e;
	integer cnt = 0;
	initial begin
		f_e = $fopen("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_outdata/color_enhance_bin_debug.txt", "w");
		#0 @(posedge rst_n);
		while (cnt <= 1448*1072) begin
			@(negedge clk)
			$fwrite(f_e, "%d : L= %d A= %d B= %d LE= %d AE= %d BE= %d\n", 
			cnt, $signed(L_data), $signed(A_data), $signed(B_data), 
			$signed(LE_data), $signed(AE_data), $signed(BE_data));
			cnt = cnt + 1;
		end
		#10 $fclose(f_e);
	end
	*/
	// synthesis translate_on
	
	
endmodule
