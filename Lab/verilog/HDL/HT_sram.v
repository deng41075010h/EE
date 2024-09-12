`timescale 1ns/100ps

module HT_SRAM(
	input rst_n,
	input clk,
	input [10:0] HT_B_SRAM_ADDR,
	input [10:0] HT_G_SRAM_ADDR,
	input [10:0] HT_R_SRAM_ADDR,
	input [15:0] HT_B_SRAM_D_IN,
	input [15:0] HT_G_SRAM_D_IN,
	input [15:0] HT_R_SRAM_D_IN,
	input ht_sram_b_wren,
	input ht_sram_g_wren,
	input ht_sram_r_wren,
	output [15:0] HT_B_SRAM_Q,
	output [15:0] HT_G_SRAM_Q,
	output [15:0] HT_R_SRAM_Q,
	output osram_rst_n // rst2_n
);

	reg [10:0] ADDR_cnt;
	reg [2:0] State, State_next;
	reg rst_phase_act;

	wire [10:0] SRAM_B_ADDR, SRAM_G_ADDR, SRAM_R_ADDR;
	wire [15:0] SRAM_B_DIN, SRAM_G_DIN, SRAM_R_DIN;
	wire [15:0] SRAM_B_Q, SRAM_G_Q, SRAM_R_Q;
	wire sram_b_wren, sram_g_wren, sram_r_wren;

	// inital clean to 0
	assign SRAM_B_ADDR = (rst_phase_act == 1) ? ADDR_cnt : HT_B_SRAM_ADDR;
	assign SRAM_G_ADDR = (rst_phase_act == 1) ? ADDR_cnt : HT_G_SRAM_ADDR;
	assign SRAM_R_ADDR = (rst_phase_act == 1) ? ADDR_cnt : HT_R_SRAM_ADDR;

	assign SRAM_B_DIN = (rst_phase_act == 1) ? 16'b0 : HT_B_SRAM_D_IN;
	assign SRAM_G_DIN = (rst_phase_act == 1) ? 16'b0 : HT_G_SRAM_D_IN;
	assign SRAM_R_DIN = (rst_phase_act == 1) ? 16'b0 : HT_R_SRAM_D_IN;

	assign HT_B_SRAM_Q = (rst_phase_act == 1) ? 16'b1 : SRAM_B_Q;
	assign HT_G_SRAM_Q = (rst_phase_act == 1) ? 16'b1 : SRAM_G_Q;
	assign HT_R_SRAM_Q = (rst_phase_act == 1) ? 16'b1 : SRAM_R_Q;

	assign sram_b_wren = (rst_phase_act == 1) ? 1'b1 : ht_sram_b_wren;
	assign sram_g_wren = (rst_phase_act == 1) ? 1'b1: ht_sram_g_wren;
	assign sram_r_wren = (rst_phase_act == 1) ? 1'b1 : ht_sram_r_wren;



	HF_B_SRAM HT_B_SRAM (
		.address(SRAM_B_ADDR),
		.clock(clk),
		.data(SRAM_B_DIN),
		.wren(sram_b_wren),
		.q(SRAM_B_Q)
	);
	
	HF_G_SRAM HT_G_SRAM (
		.address(SRAM_G_ADDR),
		.clock(clk),
		.data(SRAM_G_DIN),
		.wren(sram_g_wren),
		.q(SRAM_G_Q)
	);
	
	HF_R_SRAM HT_R_SRAM (
		.address(SRAM_R_ADDR),
		.clock(clk),
		.data(SRAM_R_DIN),
		.wren(sram_r_wren),
		.q(SRAM_R_Q)
	);
	
	// FSM 
	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 0) 
			State <= 3'b001;
		else
			State <= State_next;
	end
			
	always @(*) begin
		case (State)
			3'b001 : begin	// S0
				State_next <= 3'b010;
			end
			3'b010 : begin	// S1
				if (ADDR_cnt > 11'd0)
					State_next <= 3'b010;
				else			// if ADDR_cnt == 0
					State_next <= 3'b100;
			end
			3'b100: begin	// S2
				State_next <= 3'b100;
			end
			default : begin
				State_next <= State;
			end
		endcase
	end
	
	always @(State) begin
		case (State)
			3'b001: begin	// S0
				rst_phase_act <= 1'b1;
			end
			3'b010: begin	// S1
				rst_phase_act <= 1'b1;
			end
			3'b100: begin	// S2
				rst_phase_act <= 1'b0;
			end
			default: begin
				rst_phase_act <= 1'b0;
			end
		endcase
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 0)
			ADDR_cnt <= 11'h7ff;
		else if (State == 3'b001)
			ADDR_cnt <= 11'h7ff;
		else if (State == 3'b010)
			ADDR_cnt <= ADDR_cnt - 11'd1;
		else if (State == 3'b100)
			ADDR_cnt <= 11'd0;
		else
			ADDR_cnt <= 11'd0;
	end
	
	
	assign osram_rst_n = ~rst_phase_act;

endmodule
