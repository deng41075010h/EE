`timescale 1ns/100ps

module Pixel_memory(
	input rst_n,
	input clk50,
//	output [12:0] DRAM_ADDR,
//	output [1:0] DRAM_BA,
//	output dram_cas_n,
//	output dram_cke,
//	output dram_clk,
//	output dram_cs_n,	
//	inout [31:0] DRAM_DQ,
//	output [3:0] dram_dqm,
//	output dram_ras_n,
//	output dram_we_n,
	output [31:0] L_data,
	output [31:0] A_data,
	output [31:0] B_data,
	output pixel_clk,
	output [11:0] Pixel_Col_cnt,
	output [11:0] Pixel_Row_cnt,
	input [7:0] RM_data,
	input [7:0] GM_data,
	input [7:0] BM_data
);


	reg [96-1:0] memory_0 [66:0][1448 - 1:0];	// [1448 * 1072 - 1:0];
	reg [96-1:0] memory_1 [66:0][1448 - 1:0];
	reg [96-1:0] memory_2 [66:0][1448 - 1:0];
	reg [96-1:0] memory_3 [66:0][1448 - 1:0];
	reg [96-1:0] memory_4 [66:0][1448 - 1:0];
	reg [96-1:0] memory_5 [66:0][1448 - 1:0];
	reg [96-1:0] memory_6 [66:0][1448 - 1:0];
	reg [96-1:0] memory_7 [66:0][1448 - 1:0];
	reg [96-1:0] memory_8 [66:0][1448 - 1:0];
	reg [96-1:0] memory_9 [66:0][1448 - 1:0];
	reg [96-1:0] memory_10 [66:0][1448 - 1:0];
	reg [96-1:0] memory_11 [66:0][1448 - 1:0];
	reg [96-1:0] memory_12 [66:0][1448 - 1:0];
	reg [96-1:0] memory_13 [66:0][1448 - 1:0];
	reg [96-1:0] memory_14 [66:0][1448 - 1:0];
	reg [96-1:0] memory_15 [66:0][1448 - 1:0];
	
	reg [96-1:0] Para_data;
	reg [11:0] Pixel_Col;
	reg [11:0] Pixel_Row, Pixel_Row_66;


	wire clk = clk50;

	integer f;


	// synthesis translate_off
	initial
		begin
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_0.dat", memory_0,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_1.dat", memory_1,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_2.dat", memory_2,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_3.dat", memory_3,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_4.dat", memory_4,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_5.dat", memory_5,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_6.dat", memory_6,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_7.dat", memory_7,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_8.dat", memory_8,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_9.dat", memory_9,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_10.dat", memory_10,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_11.dat", memory_11,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_12.dat", memory_12,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_13.dat", memory_13,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_14.dat", memory_14,0);
			$readmemh("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_data/pixel_rom_15.dat", memory_15,0);
		end
	// synthesis translate_on

	
	assign L_data = Para_data[96-1:64];
	assign A_data = Para_data[64-1:32];
	assign B_data = Para_data[32-1:0];

	
	always @(*) begin
		if (Pixel_Row < 12'd67) begin
			Pixel_Row_66 = Pixel_Row;
			Para_data = memory_0[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 1 * 12'd67 && Pixel_Row < 2 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd67;
			Para_data = memory_1[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 2 * 12'd67 && Pixel_Row < 3 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd134; // 67 * 2
			Para_data = memory_2[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 3 * 12'd67 && Pixel_Row < 4 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd201; // 67 * 3
			Para_data = memory_3[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 4 * 12'd67 && Pixel_Row < 5 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd268; // 67 * 4
			Para_data = memory_4[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 5 * 12'd67 && Pixel_Row < 6 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd335; // 67 * 5
			Para_data = memory_5[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 6 * 12'd67 && Pixel_Row < 7 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd402; // 67 * 6
			Para_data = memory_6[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 7 * 12'd67 && Pixel_Row < 8 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd469; // 67 * 7
			Para_data = memory_7[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 8* 12'd67 && Pixel_Row < 9 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd536; // 67 * 8
			Para_data = memory_8[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 9 * 12'd67 && Pixel_Row < 10 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd603; // 67 * 9
			Para_data = memory_9[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 10 * 12'd67 && Pixel_Row < 11 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd670; // 67 * 10
			Para_data = memory_10[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 11 * 12'd67 && Pixel_Row < 12 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd737; // 67 * 11
			Para_data = memory_11[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 12 * 12'd67 && Pixel_Row < 13 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd804; // 67 * 12
			Para_data = memory_12[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 13 * 12'd67 && Pixel_Row < 14 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd871; // 67 * 13
			Para_data = memory_13[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 14 * 12'd67 && Pixel_Row < 15 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd938; // 67 * 14
			Para_data = memory_14[Pixel_Row_66][Pixel_Col];
		end
		else if (Pixel_Row >= 15 * 12'd67 && Pixel_Row < 16 * 12'd67) begin
			Pixel_Row_66 = Pixel_Row - 12'd1005; // 67 * 15
			Para_data = memory_15[Pixel_Row_66][Pixel_Col];
		end
	end

	
	always @(negedge clk or negedge rst_n) begin

		if(rst_n == 0)
			Pixel_Col <= 12'h0;
		else if (Pixel_Col >= 12'd1447)
			Pixel_Col <= 12'h0;
		else
			Pixel_Col <= Pixel_Col + 12'h001;
	end
	
	always @(negedge clk or negedge rst_n) begin
		if (rst_n == 0)
			Pixel_Row <= 12'h0;
		else if (Pixel_Col == 12'd1447 && Pixel_Row >= 12'd1071)
			Pixel_Row <= 12'h0;
		else if (Pixel_Col == 12'd1447 && Pixel_Row < 12'd1072)
			Pixel_Row <= Pixel_Row + 12'h001;
		
	end
	
	assign Pixel_Col_cnt[11:0] = Pixel_Col[11:0];
	assign Pixel_Row_cnt[11:0] = Pixel_Row[11:0];
	assign pixel_clk = clk;
	
	
	// debug process
	// synthesis translate_off
	integer f_out;
	integer cnt = 0;
	initial begin
	  f_out = $fopen("C:/Users/joyce/Documents/QuartusProjects/DE2-115_Sean/TB/sim_outdata/memout_bin_debug.txt", "w");
	  #0 @(posedge rst_n);
	  while (cnt <= 1448*1072) begin
			@(negedge pixel_clk)
			$fwrite(f_out, "row %d, col %d : BC = %d GC = %d RC = %d\n",
			Pixel_Row, Pixel_Col, BM_data, GM_data, RM_data);
			cnt = cnt + 1;
		end
	  #10 $fclose(f_out);
	end
	
	// synthesis translate_on

endmodule

