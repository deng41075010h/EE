`timescale 1ns/100ps
module Float2fix(
	input rst_n,
	input clk,  // pixel_clk
	input [31:0] L_fp,
	input [31:0] A_fp,
	input [31:0] B_fp,
	output [31:0] L_bin,
	output [31:0] A_bin,
	output [31:0] B_bin
);

	convert cvt_L (
		.fp(L_fp),  // input [31:0] 
		.bin(L_bin) // output [31:0] 
	);
	convert cvt_A (
		.fp(A_fp),  // input [31:0] 
		.bin(A_bin) // output [31:0] 
	);
	convert cvt_B (
		.fp(B_fp),  // input [31:0] 
		.bin(B_bin) // output [31:0] 
	);



endmodule

module convert (
	input [31:0] fp,
	output [31:0] bin
);

wire [8:0] EXP_1;
wire [7:0] EXP;
reg [7:0] int;
reg [22:0] dec;
wire [31:0] bin_data;


assign EXP_1 = -127 + {1'b0, fp[30:23]};

// 1 bit sign bit, 8 bit int, 23 bit fraction

always @(*) begin
	int <= 8'b0;
	if (EXP_1[8] == 0) begin
		case (EXP_1[7:0])
			8'h00: begin	// 8'h7F, 2^0
				int <= {8'h01};
				dec <= fp[22:0];
			end
			8'h01: begin	// 8'h80, 2^1
				int <= {6'b0, 1'b1, fp[22]};
				dec <= {fp[21:0], 1'b0};
			end
			8'h02: begin	// 8'h81, 2^2
				int <= {5'b0, 1'b1, fp[22:21]};
				dec <= {fp[20:0], 2'b0};
			end
			8'h03: begin	// 8'h82, 2^3
				int <= {4'b0, 1'b1, fp[22:20]};
				dec <= {fp[19:0], 3'b0};
			end
			8'h04: begin	// 8'h83, 2^4
				int <= {3'b0, 1'b1, fp[22:19]};
				dec <= {fp[18:0], 4'b0};
			end
			8'h05: begin	// 8'h84, 2^5
				int <= {2'b0, 1'b1, fp[22:18]};
				dec <= {fp[17:0], 5'b0};
			end
			8'h06: begin	// 8'h85, 2^6
				int <= {1'b0, 1'b1, fp[22:17]};
				dec <= {fp[16:0], 6'b0};
			end
			8'h07: begin	// 8'h86, 2^7
				int <= {1'b1, fp[22:16]};
				dec <= {fp[15:0], 7'b0};
			end
			default: begin
				int <= {8'hff};
				dec <= {fp[15:0], 7'b0};
			end
		endcase
	end
	else begin //	EXP_1[8] == 1
		case (EXP_1[7:0])
			8'h81: begin // IEEE754 exp = 0
				int <= {8'b0};
				dec <= 23'b0;
			end
			8'hFF: begin	//8'h7E, 2^(-1)
				int <= {8'b0};
				dec <= {1'b1, fp[22:1]};
			end
			8'hFE: begin	// 8'h7D, 2^(-2)
				int <= {8'b0};
				dec <= {2'b01, fp[22:2]};
			end
			8'hFD: begin	//8'h7C, 2^(-3)
				int <= {8'b0};
				dec <= {3'b001, fp[22:3]};
			end
			8'hFC: begin	// 8'h7B, 2^(-4)
				int <= {8'b0};
				dec <= {4'b0001, fp[22:4]};
			end
			8'hFB: begin	// 8'h7A, 2^(-5)
				int <= {8'b0};
				dec <= {5'b00001, fp[22:5]};
			end
			8'hFA: begin	// 8'h79, 2^(-6)
				int <= {8'b0};
				dec <= {6'b000001, fp[22:6]};
			end
			8'hF9: begin	// 8'h78, 2^(-7)
				int <= {8'b0};
				dec <= {7'b0000001, fp[22:7]};
			end
			8'hF8: begin	// 8'h77, 2^(-8)
				int <= {8'b0};
				dec <= {8'b00000001, fp[22:8]};
			end
			8'hF7: begin	// 8'h76, 2^(-9)
				int <= {8'b0};
				dec <= {9'b000000001, fp[22:9]};
			end
			8'hF6: begin	// 8'h75, 2^(-10)
				int <= {8'b0};
				dec <= {10'b0000000001, fp[22:10]};
			end
			default: begin
				int <= 8'b0;
				dec <= {11'b00000000001,fp[22:11]};
			end
		endcase	
	end
end
		

		
		
assign bin_data = {1'b0, int[7:0], dec[22:0]};
assign bin = (fp[31] == 1) ? (~bin_data[31:0] + 1'b1) : bin_data;


endmodule
