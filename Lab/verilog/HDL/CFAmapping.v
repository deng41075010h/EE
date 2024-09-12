`timescale 1ns/100ps

module CFAmapping (
	input rst_n, // rst2_n
	input clk,   // pixel_clk
	input [7:0] R,
	input [7:0] G,
	input [7:0] B,
	output [7:0] cfa_R,
	output [7:0] cfa_G,
	output [7:0] cfa_B
);

	reg [1:0] row_cnt;
	reg [3:0] col_cnt;
	reg [11:0] pixel_col;
	reg [1:0] state;
	reg [7:0] cfaR, cfaG, cfaB;
	
	always @(negedge clk or negedge rst_n) begin
		if (rst_n == 0) begin
			col_cnt <= 4'd0;
		end
		else if (pixel_col == 12'd1447) begin
			col_cnt <= 4'd0;
		end
		else if (col_cnt >= 4'd8) begin
			col_cnt <= 4'd0;
		end
		else begin
			col_cnt <= col_cnt + 4'd1;
		end
	end
	
	always @(negedge clk or negedge rst_n) begin

		if(rst_n == 0)
			pixel_col <= 12'h0;
		else if (pixel_col >= 12'd1447)
			pixel_col <= 12'h0;
		else
			pixel_col <= pixel_col + 12'h001;
	end
	
	always @(negedge clk or negedge rst_n) begin
		if (rst_n == 0)
			row_cnt <= 2'd0;
		else if (pixel_col == 12'd1447 && row_cnt >= 2'd2)
			row_cnt <= 2'd0;
		else if (pixel_col == 12'd1447)
			row_cnt <= row_cnt + 2'd1;
	end
	
	
	always @(*) begin
		if (row_cnt == 2'd0) begin
			if (col_cnt >= 4'd0 && col_cnt <= 4'd2)
				state <= 2'd0;
			else if (col_cnt >= 4'd3 && col_cnt <= 4'd5)
				state <= 2'd1;
			else if (col_cnt >= 4'd6 && col_cnt <= 4'd8)
				state <= 2'd2;
			else
				state <= 2'd3;
		end
		else if (row_cnt == 2'd1) begin
			if (col_cnt >= 4'd0 && col_cnt <= 4'd2)
				state <= 2'd1;
			else if (col_cnt >= 4'd3 && col_cnt <= 4'd5)
				state <= 2'd2;
			else if (col_cnt >= 4'd6 && col_cnt <= 4'd8)
				state <= 2'd0;
			else
				state <= 2'd3;
		end
		else if (row_cnt == 2'd2) begin
			if (col_cnt >= 4'd0 && col_cnt <= 4'd2)
				state <= 2'd2;
			else if (col_cnt >= 4'd3 && col_cnt <= 4'd5)
				state <= 2'd0;
			else if (col_cnt >= 4'd6 && col_cnt <= 4'd8)
				state <= 2'd1;
			else
				state <= 2'd3;
		end
		else
			state <= 2'd3;
	end
	
	always @(*) begin
		case (state)
			2'd0 :
				begin
					cfaR <= R;
					cfaG <= R;
					cfaB <= R;
				end
			2'd1 :
				begin
					cfaR <= G;
					cfaG <= G;
					cfaB <= G;
				end
			2'd2 :
				begin
					cfaR <= B;
					cfaG <= B;
					cfaB <= B;
				end
			2'd3 :
				begin
					cfaR <= 8'hff;
					cfaG <= 8'hff;
					cfaB <= 8'hff;
				end
		endcase
	end
	
	assign cfa_R = cfaR;
	assign cfa_G = cfaG;
	assign cfa_B = cfaB;
	

endmodule
