`timescale 1ns/100ps

module Lab2rgb(
	input rst_n,	// rst2_n
	input clk,     // pixel_clk
	input [31:0] LE_data,
	input [31:0] AE_data,
	input [31:0] BE_data,
	output [31:0] BC_data,
	output [31:0] GC_data,
	output [31:0] RC_data
);

	wire [31:0] X, Y, Z;
	wire [31:0] R, G, B;
	wire [31:0] r0, g0, b0;
	wire [31:0] r1, g1, b1;
	wire cmp_r0, cmp_g0, cmp_b0;
	wire cmp_r1, cmp_g1, cmp_b1;
	
	// 1 bit sign, 8 bit int, 23 bit fraction
	wire [31:0] const_1 = 32'b00000000100000000000000000000000; // 1
	wire [31:0] const_255 = 32'b01111111100000000000000000000000; // 255

	
	Lab2XYZ lab2xyz (
		.L(LE_data),
		.a(AE_data),
		.b(BE_data),
		.X(X),
		.Y(Y),
		.Z(Z)
	);
	
	XYZ2RGB xyz2rgb (
		.X(X),
		.Y(Y),
		.Z(Z),
		.R(R),
		.G(G),
		.B(B)
	);

	// if(RGB < 0) RGB = 0;
	Comparator cmp_R0 (.a(32'd0), .b(R), .q(cmp_r0));
	assign r0 = (cmp_r0) ? 32'd0 : R;
	
	Comparator cmp_G0 (.a(32'd0), .b(G), .q(cmp_g0));
	assign g0 = (cmp_g0) ? 32'd0 : G;
	
	Comparator cmp_B0 (.a(32'd0), .b(B), .q(cmp_b0));
	assign b0 = (cmp_b0) ? 32'd0 : B;
	
	
	// if(RGB > 1) RGB = 1;
	Comparator cmp_R1 (.a(R), .b(const_1), .q(cmp_r1));
	assign r1 = (cmp_r1) ? const_1 : r0;
	
	Comparator cmp_G1 (.a(G), .b(const_1), .q(cmp_g1));
	assign g1 = (cmp_g1) ? const_1 : g0;
	
	Comparator cmp_B1 (.a(B), .b(const_1), .q(cmp_b1));
	assign b1 = (cmp_b1) ? const_1 : b0;
	
	
	// RGB * 255;
	Multiplier mul_R (.a(r1), .b(const_255), .q(RC_data));
	Multiplier mul_G (.a(g1), .b(const_255), .q(GC_data));
	Multiplier mul_B (.a(b1), .b(const_255), .q(BC_data));


	// debug process
	// synthesis translate_off

/*	
	integer f1;
	integer cnt = 0;
	initial begin
	  f1 = $fopen("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_outdata/Lab2rgb_bin_debug.txt", "w");
	  #0 @(posedge rst_n);
	  while (cnt <= 1448*1072) begin
			@(negedge clk)
			$fwrite(f1, "%d : LE= %d AE= %d BE= %d BC= %d GC= %d RC= %d\n",
			cnt, $signed(LE_data), $signed(AE_data), $signed(BE_data),
			$signed(BC_data), $signed(GC_data), $signed(RC_data));
			cnt = cnt + 1;
		end
	  #10 $fclose(f1);
	end
*/	 
	 
	// synthesis translate_on


endmodule

module Lab2XYZ(
	input [31:0] L,
	input [31:0] a,
	input [31:0] b,
	output [31:0] X,
	output [31:0] Y,
	output [31:0] Z
);

	// 1 bit sign, 8 bit int, 23 bit fraction
	wire [31:0] const_Xn = 32'b00000000011110011010100010001011; // 0.950456f
	wire [31:0] const_Yn = 32'b00000000100000000000000000000000; // 1.0f
	wire [31:0] const_Zn = 32'b00000000100010110101110001001011; // 1.088754f
	wire [31:0] const_param_16116 = 32'b00000000000100011010011110111001; // (16.0 / 116)
	wire [31:0] const_16 = 32'b00001000000000000000000000000000; // 16.0f
	wire [31:0] const_1_116 = 32'b00000000000000010001101001111011; // (1.0 / 116)
	wire [31:0] const_1_500 = 32'b00000000000000000100000110001001; // (1.0 / 500)
	wire [31:0] const_1_200 = 32'b00000000000000001010001111010111; // (1.0 / 200)
	wire [31:0] const_param_8856 = 32'b00000000000000010010001000110001; // 0.008856f
	wire [31:0] const_param_7787 = 32'b00000000000100000111000000001010; // (1.0 / 7.787)
	
	
	wire [31:0] temp_L, temp_a, temp_b;
	wire [31:0] temp_fY, temp_fX, temp_fZ;
	wire [31:0] temp_fY2, temp_fX2, temp_fZ2;
	wire [31:0] temp_fY3, temp_fX3, temp_fZ3;
	wire [31:0] temp_Y, temp_X, temp_Z;
	wire [31:0] Y_0, Y_1, X_0, X_1, Z_0, Z_1;
	wire cmp_Y, cmp_X, cmp_Z;
	wire [31:0] qY, qX, qZ;
	
	// fY = (L + 16) / 116;
	Adder add_L (.a(L), .b(const_16), .q(temp_L));
	Multiplier mul_L (.a(temp_L), .b(const_1_116), .q(temp_fY));

	// fX = a / 500.0f + fY;
	Multiplier mul_a (.a(a), .b(const_1_500), .q(temp_a));
	Adder add_a (.a(temp_a), .b(temp_fY), .q(temp_fX));

	// fZ = fY - b / 200.0f;
	Multiplier mul_b (.a(b), .b(const_1_200), .q(temp_b));
	Subtractor sub_b (.a(temp_fY), .b(temp_b), .q(temp_fZ));

	
	
	// fY * fY * fY
	Multiplier mul_fY1 (.a(temp_fY), .b(temp_fY), .q(temp_fY2));
	Multiplier mul_fY2 (.a(temp_fY), .b(temp_fY2), .q(temp_fY3));

	// fX * fX * fX
	Multiplier mul_fX1 (.a(temp_fX), .b(temp_fX), .q(temp_fX2));
	Multiplier mul_fX2 (.a(temp_fX), .b(temp_fX2), .q(temp_fX3));

	// fZ * fZ * fZ
	Multiplier mul_fZ1 (.a(temp_fZ), .b(temp_fZ), .q(temp_fZ2));
	Multiplier mul_fZ2 (.a(temp_fZ), .b(temp_fZ2), .q(temp_fZ3));	

	
	
	// Y = (fY - param_16116) / 7.787f;
	Subtractor sub_Y (.a(temp_fY), .b(const_param_16116), .q(temp_Y));
	Multiplier mul_Y (.a(temp_Y), .b(const_param_7787), .q(Y_0));

	// X = (fX - param_16116) / 7.787f;
	Subtractor sub_X (.a(temp_fX), .b(const_param_16116), .q(temp_X));
	Multiplier mul_X (.a(temp_X), .b(const_param_7787), .q(X_0));

	// Z = (fZ - param_16116) / 7.787f;
	Subtractor sub_Z (.a(temp_fZ), .b(const_param_16116), .q(temp_Z));
	Multiplier mul_Z (.a(temp_Z), .b(const_param_7787), .q(Z_0));

	
	
	// compare 0.008856
	Comparator cmp_fY (.a(temp_fY3), .b(const_param_8856), .q(cmp_Y));
	Comparator cmp_fX (.a(temp_fX3), .b(const_param_8856), .q(cmp_X));
	Comparator cmp_fZ (.a(temp_fZ3), .b(const_param_8856), .q(cmp_Z));

	assign Y_1 = temp_fY3;
	assign X_1 = temp_fX3;
	assign Z_1 = temp_fZ3;
	
	assign qY = (cmp_Y==1) ? Y_1 : Y_0;
	assign qX = (cmp_X==1) ? X_1 : X_0;
	assign qZ = (cmp_Z==1) ? Z_1 : Z_0;
	
	
	// Y *= Yn, X *= Xn, Z *= Zn
	Multiplier mul_Yn (.a(qY), .b(const_Yn), .q(Y));
	Multiplier mul_Xn (.a(qX), .b(const_Xn), .q(X));
	Multiplier mul_Zn (.a(qZ), .b(const_Zn), .q(Z));


endmodule

module XYZ2RGB (
	input [31:0] X,
	input [31:0] Y,
	input [31:0] Z,
	output [31:0] R,
	output [31:0] G,
	output [31:0] B
);

	// 1 bit sign, 8 bit int, 23 bit fraction
	wire [31:0] const_rX = 32'b00000001100111101100011100110100; // 3.2404542f
	wire [31:0] const_rY = 32'b11111111001110110011111100001100; // -1.5371385f
	wire [31:0] const_rZ = 32'b11111111110000000011000000100000; // -0.4985314f
	wire [31:0] const_gX = 32'b11111111100000111110111100011000; // -0.9692660f
	wire [31:0] const_gY = 32'b00000000111100000010000100011111; // 1.8760108f
	wire [31:0] const_gZ = 32'b00000000000001010101000110110101; // 0.0415560f
	wire [31:0] const_bX = 32'b00000000000001110001111101010010; // 0.0556434f
	wire [31:0] const_bY = 32'b11111111111001011110001001111011; // -0.2040259f
	wire [31:0] const_bZ = 32'b00000000100001110101001100101000; // 1.0572252f


	wire [31:0] rX, rY, rZ;
	wire [31:0] gX, gY, gZ;
	wire [31:0] bX, bY, bZ;
	wire [31:0] temp_r, temp_g, temp_b;
	
	// R
	Multiplier mul_rX (.a(X), .b(const_rX), .q(rX));
	Multiplier mul_rY (.a(Y), .b(const_rY), .q(rY));
	Multiplier mul_rZ (.a(Z), .b(const_rZ), .q(rZ));
	Adder add_r1 (.a(rX), .b(rY), .q(temp_r));
	Adder add_r2 (.a(temp_r), .b(rZ), .q(R));

	// G
	Multiplier mul_gX (.a(X), .b(const_gX), .q(gX));
	Multiplier mul_gY (.a(Y), .b(const_gY), .q(gY));
	Multiplier mul_gZ (.a(Z), .b(const_gZ), .q(gZ));
	Adder add_g1 (.a(gX), .b(gY), .q(temp_g));
	Adder add_g2 (.a(temp_g), .b(gZ), .q(G));

	// B
	Multiplier mul_bX (.a(X), .b(const_bX), .q(bX));
	Multiplier mul_bY (.a(Y), .b(const_bY), .q(bY));
	Multiplier mul_bZ (.a(Z), .b(const_bZ), .q(bZ));
	Adder add_b1 (.a(bX), .b(bY), .q(temp_b));
	Adder add_b2 (.a(temp_b), .b(bZ), .q(B));

	
endmodule
