`timescale 1ns/100ps

module Halftone(
	input rst_n,	// rst2_n
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
	
	input [15:0] HT_B_SRAM_QI,
	input [15:0] HT_G_SRAM_QI,
	input [15:0] HT_R_SRAM_QI,
	output reg [15:0] HT_B_SRAM_D_OUT,
	output reg [15:0] HT_G_SRAM_D_OUT,
	output reg [15:0] HT_R_SRAM_D_OUT,
	output reg [10:0] HT_B_SRAM_ADDR,
	output reg [10:0] HT_G_SRAM_ADDR,
	output reg [10:0] HT_R_SRAM_ADDR,
	output ht_sram_b_wren, 
	output ht_sram_g_wren,
	output ht_sram_r_wren
);

	
	reg [15:0] r1_in_R, r2_in_R, r3_in_R;
	reg [15:0] r1_in_G, r2_in_G, r3_in_G;
	reg [15:0] r1_in_B, r2_in_B, r3_in_B;

	
	wire [15:0] RC_bin, GC_bin, BC_bin;
	wire [15:0] R_new, G_new, B_new;
	
	
	// 32 bit (1 sign bit, 8 bit int, 23 bit fraction)
	// 16 bit (1 sign bit, 8 bit int, 7 bit fraction)
	// 32 bit to 16 bit
	assign RC_bin = RC_data[31:16];
	assign GC_bin = GC_data[31:16];
	assign BC_bin = BC_data[31:16];
	
	
	reg [1:0] state;
	reg rd_en, wr_en, reset;

	assign ht_sram_b_wren = wr_en;
	assign ht_sram_g_wren = wr_en;
	assign ht_sram_r_wren = wr_en;
	
	// generate pixel_clk reset pulse
	reg [2:0] clk_cnt;
	wire [2:0] max_cnt = 3'b011; // 3
	
	always @(negedge clk200 or negedge rst_n) begin
		if(rst_n == 0) begin
			clk_cnt <= 3'b0;
			reset <= 0; 
		end
		else begin
			if (clk_cnt == 0) begin
				reset <= 0; 
			end
			if (clk_cnt < max_cnt) begin
				clk_cnt <= clk_cnt + 3'b1;
			end
			else if (clk_cnt == max_cnt) begin
				reset <= ~reset;
				clk_cnt <= 3'b0;
			end
		end
	end
	
	
	///////////////////////////////////////
	
	
	always @(*) begin
		if (reset == 1) begin
			state <= 2'b00; 
		end
		else if (clk_cnt == 3'd1) begin
			state <= 2'b01;
		end
		else if (clk_cnt == 3'd2) begin
			state <= 2'b10;
		end
		else
			state <= 2'b00;
	end
	
	always @(*) begin
		case (state)
			2'b00: begin
				rd_en <= 0;
				wr_en <= 0;
			end
			2'b01: begin
				rd_en <= 1;
				wr_en <= 0;
			end
			2'b10: begin
				rd_en <= 0;
				wr_en <= 1;
			end
		endcase
	end
	
	// read error from memory
	reg [15:0] errStorageR, errStorageG, errStorageB;

	
	// calculate Pixel = Pixel + error(r2+r3+r4) + r1
	calPixel calBpixel (
		.pixel(BC_bin), .r1(r1_in_B), .errorStorage(errStorageB), .newPixel(B_new)
	);
	calPixel calGpixel (
		.pixel(GC_bin), .r1(r1_in_G), .errorStorage(errStorageG), .newPixel(G_new)
	);
	calPixel calRpixel (
		.pixel(RC_bin), .r1(r1_in_R), .errorStorage(errStorageR), .newPixel(R_new)
	);
	
	// Error Diffusion and fit to 16 level
	integer i;
	integer const_8 = 8;
	integer const_16 = 16;
	
	reg [8:0] RLv_int, GLv_int, BLv_int;
	reg [15:0] R_err, G_err, B_err;
	

	always @(*) begin
		for (i = 0; i < 16; i = i + 1) begin
			if ((R_new[14:7] >= (i) * const_16) && (R_new[14:7] < (i) * const_16 + const_8)) begin
				RLv_int <= const_16 * i;
				R_err <= R_new - {RLv_int, 7'b0};
			end
			else if ((R_new[14:7] >= (i) * const_16 + const_8) && (R_new[14:7] < (i + 1) * const_16)) begin
				RLv_int <= const_16 * (i + 1);
				R_err <= R_new - {RLv_int, 7'b0};
			end
		end
	end	

	always @(*) begin
		for (i = 0; i < 16; i = i + 1) begin
			if ((G_new[14:7] >= (i) * const_16) && (G_new[14:7] < (i) * const_16 + const_8)) begin
				GLv_int <= const_16 * i;
				G_err <= G_new - {GLv_int, 7'b0};
			end
			else if ((G_new[14:7] >= (i) * const_16 + const_8) && (G_new[14:7] < (i + 1) * const_16)) begin
				GLv_int <= const_16 * (i + 1);
				G_err <= G_new - {GLv_int, 7'b0};
			end
		end
	end	

	always @(*) begin
		for (i = 0; i < 16; i = i + 1) begin
			if ((B_new[14:7] >= (i) * const_16) && (B_new[14:7] < (i) * const_16 + const_8)) begin
				BLv_int <= const_16 * i;
				B_err <= B_new - {BLv_int, 7'b0};
			end
			else if ((B_new[14:7] >= (i) * const_16 + const_8) && (B_new[14:7] < (i + 1) * const_16)) begin
				BLv_int <= const_16 * (i + 1);
				B_err <= B_new - {BLv_int, 7'b0};
			end
		end
	end
	
	wire [15:0] r1_out_R, r2_out_R, r3_out_R, r4_out_R;
	wire [15:0] r1_out_G, r2_out_G, r3_out_G, r4_out_G;
	wire [15:0] r1_out_B, r2_out_B, r3_out_B, r4_out_B;
	wire [2:0] write_r4_en, write_r3_en;
	
	Floyd_Steinberg_algorithm FS_R (
		.row(Pixel_Row),              // input [11:0]
		.col(Pixel_Col),              // input [11:0]
		.err(R_err),                  // input [15:0]
		.r2_in(r2_in_R),              // input [15:0]
		.r3_in(r3_in_R),              // input [15:0]
		.r1_out(r1_out_R),            // output [15:0]
		.r2_out(r2_out_R),            // output [15:0]
		.r3_out(r3_out_R),            // output [15:0]
		.r4_out(r4_out_R),            // output [15:0]
		.write_r4_en(write_r4_en[0]), // output
		.write_r3_en(write_r3_en[0])  // output
	);
	
	Floyd_Steinberg_algorithm FS_G (
		.row(Pixel_Row),              // input [11:0]
		.col(Pixel_Col),              // input [11:0]
		.err(G_err),                  // input [15:0]
		.r2_in(r2_in_G),              // input [15:0]
		.r3_in(r3_in_G),              // input [15:0]
		.r1_out(r1_out_G),            // output [15:0]
		.r2_out(r2_out_G),            // output [15:0]
		.r3_out(r3_out_G),            // output [15:0]
		.r4_out(r4_out_G),            // output [15:0]
		.write_r4_en(write_r4_en[1]), // output
		.write_r3_en(write_r3_en[1])  // output
	);
	
	Floyd_Steinberg_algorithm FS_B (
		.row(Pixel_Row),              // input [11:0]
		.col(Pixel_Col),              // input [11:0]
		.err(B_err),                  // input [15:0]
		.r2_in(r2_in_B),              // input [15:0]
		.r3_in(r3_in_B),              // input [15:0]
		.r1_out(r1_out_B),            // output [15:0]
		.r2_out(r2_out_B),            // output [15:0]
		.r3_out(r3_out_B),            // output [15:0]
		.r4_out(r4_out_B),            // output [15:0]
		.write_r4_en(write_r4_en[2]), // output
		.write_r3_en(write_r3_en[2])  // output
	);
		
		
	always @(negedge clk200 or negedge rst_n) begin
		if(rst_n == 0) begin
			r1_in_R <= 0; 
			r2_in_R <= 0;
			r3_in_R <= 0;
		end
		else if (reset == 1) begin
			r1_in_R <= r1_out_R; 
			r2_in_R <= r2_out_R;
			r3_in_R <= r3_out_R;
		end
	end
	
	always @(negedge clk200 or negedge rst_n) begin
		if(rst_n == 0) begin
			r1_in_G <= 0;
			r2_in_G <= 0;
			r3_in_G <= 0;
		end
		else if (reset == 1) begin
			r1_in_G <= r1_out_G;
			r2_in_G <= r2_out_G;
			r3_in_G <= r3_out_G;
		end
	end
	
	always @(negedge clk200 or negedge rst_n) begin
		if(rst_n == 0) begin
			r1_in_B <= 0;
			r2_in_B <= 0;
			r3_in_B <= 0;
		end
		else if (reset == 1) begin
			r1_in_B <= r1_out_B;
			r2_in_B <= r2_out_B;
			r3_in_B <= r3_out_B;
		end
	end
	
	
	// errorStorage SRAM control
	always @(*) begin
		if (rd_en == 1) begin
			HT_B_SRAM_ADDR <= Pixel_Col;
			HT_G_SRAM_ADDR <= Pixel_Col;
			HT_R_SRAM_ADDR <= Pixel_Col;		
			errStorageR <= HT_R_SRAM_QI;
			errStorageG <= HT_G_SRAM_QI;
			errStorageB <= HT_B_SRAM_QI;
		end
		else if (wr_en == 1) begin
			if (write_r4_en == 3'b111) begin
				HT_B_SRAM_ADDR <= Pixel_Col - 1;
				HT_G_SRAM_ADDR <= Pixel_Col - 1;
				HT_R_SRAM_ADDR <= Pixel_Col - 1;
				
				HT_B_SRAM_D_OUT <= r4_out_B;
				HT_G_SRAM_D_OUT <= r4_out_G;
				HT_R_SRAM_D_OUT <= r4_out_R;
			end
			else if (write_r3_en == 3'b111) begin
				HT_B_SRAM_ADDR <= Pixel_Col;
				HT_G_SRAM_ADDR <= Pixel_Col;
				HT_R_SRAM_ADDR <= Pixel_Col;
				
				HT_B_SRAM_D_OUT <= r3_out_B;
				HT_G_SRAM_D_OUT <= r3_out_G;
				HT_R_SRAM_D_OUT <= r3_out_R;
			end
		end
	end	
	
	assign R_level = RLv_int[7:0];
	assign G_level = GLv_int[7:0];
	assign B_level = BLv_int[7:0];
	
	
	 
endmodule


module calPixel(
	input [15:0] pixel,
	input [15:0] r1,
	input [15:0] errorStorage,
	output [15:0] newPixel
);
	
	// 1 bit sign, 8 bit int, 7 bit fraction
	wire [15:0] newTemp, errTemp, clip_255;
	
	assign errTemp = errorStorage + r1;
	
	assign newTemp = pixel + errTemp;
	
	// clip at 255
	assign clip_255 = (errTemp[15] == 1'b0 && newTemp[15] == 1'b1) ? 16'h7f80 : newTemp;

	
	// clip at 0 ~ 240
	// d240 = b11110000 -> new[14:7] -> int
	// 16'b011110000_0000000 -> new[6:0] -> fraction
	// new[15] -> sign bit
	//assign newPixel = (newTemp[15] == 1'b1) ? 16'h0000 : (newTemp >= 16'b0111100000000000) ? 16'h7800 : newTemp;
	assign newPixel = (clip_255[15] == 1'b1) ? 16'h0000 : (clip_255 >= 16'b0111100000000000) ? 16'h7800 : clip_255;
	
endmodule

module Floyd_Steinberg_algorithm (
	input [11:0] row,
	input [11:0] col,
	input [15:0] err,
	input [15:0] r2_in,
	input [15:0] r3_in,
	output [15:0] r1_out,
	output [15:0] r2_out,
	output [15:0] r3_out,
	output [15:0] r4_out,
	output write_r4_en,
	output write_r3_en
);

	wire [15:0] err4_t, err3_t, err2_t, err1_t; // before / 16
	wire [15:0] err4, err3, err2, err1; // 3, 5, 1, 7
	reg [15:0] r4, r3, r2, r1;
	reg wr_r4_en, wr_r3_en;
	
	
	assign err4_t = ((err << 1) + err); // *3
	assign err3_t = ((err << 2) + err); // *5
	assign err2_t = (err);              // *1
	assign err1_t = ((err << 3) - err); // *7
	
	// /16
	assign err4 = (err4_t[15] == 1) ? {4'b1111, err4_t[15:4]} : {4'b0000, err4_t[15:4]};
	assign err3 = (err3_t[15] == 1) ? {4'b1111, err3_t[15:4]} : {4'b0000, err3_t[15:4]};
	assign err2 = (err2_t[15] == 1) ? {4'b1111, err2_t[15:4]} : {4'b0000, err2_t[15:4]};
	assign err1 = (err1_t[15] == 1) ? {4'b1111, err1_t[15:4]} : {4'b0000, err1_t[15:4]};
	
	
	always @ (*) begin
		wr_r4_en <= 0;
		wr_r3_en <= 0;	
		if (col >= 12'd1 && row + 1 < 12'd1072) begin
			r4 <= r3_in + err4;
			// store r4 to memory[c][col - 1]
			wr_r4_en <= 1;
		end
		else begin
			wr_r4_en <= 0;
		end
		
		if (row + 1 < 12'd1072) begin
			r3 <= r2_in + err3;
			// store r3 to memory[c][col]
			wr_r3_en <= 1;
		end
		else begin
			wr_r3_en <= 0;
		end
		
		if (col + 1 < 12'd1448 && row + 1 < 12'd1072) begin
			r2 <= err2;
		end
		else begin
			r2 <= 16'd0; // when col = 1447, r2 = 0
		end
		
		if (col + 1 < 12'd1448) begin
			r1 <= err1;
		end
		else begin
			r1 <= 16'd0; // when col = 1447, r1 = 0
		end
	end
	
	assign r4_out = r4;
	assign r3_out = r3;
	assign r2_out = r2;
	assign r1_out = r1;
	
	assign write_r4_en = wr_r4_en;
	assign write_r3_en = wr_r3_en;

endmodule

