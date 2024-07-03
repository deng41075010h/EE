module project(clk, rst, pb, sw, p1_h,p1_t,p1_o,p2_h,p2_t,p2_o,sw_h1,sw_h2,sw_t1,sw_t2,sw_o1,sw_o2);
	input clk, rst, pb, sw,sw_h1,sw_h2,sw_t1,sw_t2,sw_o1,sw_o2;
	output [6:0] p1_h,p1_t,p1_o,p2_h,p2_t,p2_o;
	
	reg [6:0] p1_h,p1_t,p1_o,p2_h,p2_t,p2_o;
	wire [6:0] p1h,p1t,p1o,p2h,p2t,p2o;
	wire [6:0] h1p, t1p, o1p, h2p, t2p, o2p;
	
	always@(sw) begin
		if(sw==0)begin
			p1_h = p1h;
			p1_t = p1t;
			p1_o = p1o;
			p2_h = p2h;
			p2_t = p2t;
			p2_o = p2o;
		end
		else if(sw==1)begin
			p1_h = h1p;
			p1_t = t1p;
			p1_o = o1p;
			p2_h = h2p;
			p2_t = t2p;
			p2_o = o2p;
		end
	end
	
	game1(.clk(clk), .rst(rst), .p1_h(p1h), .p1_t(p1t), .p1_o(p1o), .p2_h(p2h), .p2_t(p2t), .p2_o(p2o), .sw_h1(sw_h1), .sw_h2(sw_h2), .sw_t1(sw_t1), .sw_t2(sw_t2), .sw_o1(sw_o1), .sw_o2(sw_o2));
	game2(.clk(clk), .rst(rst), .pb(pb), .h_1p(h1p), .t_1p(t1p), .o_1p(o1p), .h_2p(h2p), .t_2p(t2p), .o_2p(o2p));
	
endmodule

module game1(clk, rst,p1_h,p1_t,p1_o,p2_h,p2_t,p2_o,sw_h1,sw_h2,sw_t1,sw_t2,sw_o1,sw_o2);
	input clk, rst,sw_h1,sw_h2,sw_t1,sw_t2,sw_o1,sw_o2;
	output [6:0] p1_h,p1_t,p1_o,p2_h,p2_t,p2_o;
	
	reg [6:0] p1_h,p1_t,p1_o,p2_h,p2_t,p2_o;
	wire [6:0] p1_3,p1_2,p1_1,p2_3,p2_2,p2_1;
	reg [4:0] h1=0,t1=0,o1=0,h2=0,t2=0,o2=0;
	reg clk1=0,clk2=0,clk3=0,clk4=0;
	reg [22:0] counter,counter_t,counter_h,counter_s;
	reg [4:0] state;
	reg prints;
	
	always@(posedge clk or negedge rst)begin//delay clock o
		if(~rst)begin
			counter <= 0;
			clk1 = 0;
		end
		else if(counter==300000)begin
			counter <=0;
			clk1 = ~clk1;
		end
		else 
			counter <= counter + 1;
	end
	always@(posedge clk or negedge rst)begin//delay clock t
		if(~rst)begin
			counter_t <= 0;
			clk2 = 0;
		end
		else if(counter==200000)begin
			counter_t <=0;
			clk2 = ~clk2;
		end
		else 
			counter_t <= counter_t + 1;
	end
	always@(posedge clk or negedge rst)begin//delay clock h
		if(~rst)begin
			counter_h <= 0;
			clk3 = 0;
		end
		else if(counter_h==100000)begin
			counter_h <=0;
			clk3 = ~clk3;
		end
		else 
			counter_h <= counter_h + 1;
	end
	
	always@(posedge clk1)begin
		if(~rst)begin
			o1=0;
			o2=0;
		end
		else if(sw_o1==1 && sw_o2==0)begin
			o1=o1;
			o2=o2+1;
			if(o2>9)begin
				o2=0;
			end
		end
		else if(sw_o1==0 && sw_o2==1)begin
			o2=o2;
			o1=o1+1;
			if(o1>9)begin
				o1=0;
			end
		end
		else if(sw_o1==1 && sw_o2==1)begin
			o1=o1;
			o2=o2;
		end
		else if(sw_o1==0 && sw_o2==0)begin
			o1=o1+1;
			o2=o2+1;
			if(o1>9)begin
				o1=0;
			end
			if(o2>9)begin
				o2=0;
			end
		end
	end
	
	always@(posedge clk2)begin
		if(~rst)begin
			t1=0;
			t2=0;
		end
		else if(sw_t1==1 && sw_t2==0)begin
			t1=t1;
			t2=t2+1;
			if(t2>9)begin
				t2=0;
			end
		end
		else if(sw_t1==0 && sw_t2==1)begin
			t2=t2;
			t1=t1+1;
			if(t1>9)begin
				t1=0;
			end
		end
		else if(sw_t1==1 && sw_t2==1)begin
			t1=t1;
			t2=t2;
		end
		else if(sw_t1==0 && sw_t2==0)begin
			t1=t1+1;
			t2=t2+1;
			if(t1>9)begin
				t1=0;
			end
			if(t2>9)begin
				t2=0;
			end
		end
	end
	
	always@(posedge clk3)begin
		if(~rst)begin
			h1=0;
			h2=0;
		end
		else if(sw_h1==1 && sw_h2==0)begin
			h1=h1;
			h2=h2+1;
			if(h2>9)begin
				h2=0;
			end
		end
		else if(sw_h1==0 && sw_h2==1)begin
			h2=h2;
			h1=h1+1;
			if(h1>9)begin
				h1=0;
			end
		end
		else if(sw_h1==1 && sw_h2==1)begin
			h1=h1;
			h2=h2;
		end
		else if(sw_h1==0 && sw_h2==0)begin
			h1=h1+1;
			h2=h2+1;
			if(h1>9)begin
				h1=0;
			end
			if(h2>9)begin
				h2=0;
			end
		end
	end
	
	
	
	bcd U1(.binary(h1),.seg1(p1_3));	
	bcd U2(.binary(t1),.seg1(p1_2));	
	bcd U3(.binary(o1),.seg1(p1_1));	
	bcd U4(.binary(h2),.seg1(p2_3));	
	bcd U5(.binary(t2),.seg1(p2_2));	
	bcd U6(.binary(o2),.seg1(p2_1));	
	
	always@(posedge clk1)begin
			if(h1==h2==t1==t2==o1==o2 && sw_h1==1 && sw_h2==1 && sw_t1==1 && sw_t2==1 && sw_o1==1 && sw_o2==1)begin
				p2_o=7'b1111000; 
				p2_t=7'b0000001; 
				p2_h=7'b0001111;
				p1_o=7'b1111111; 
				p1_t=7'b0001001; 
				p1_h=7'b1000110;
			end
			else if(sw_h1==1 && sw_h2==1 && sw_t1==1 && sw_t2==1 && sw_o1==1 && sw_o2==1) begin
				p2_o=7'b0111000; 
				p2_t=7'b0111000; 
				p2_h=7'b0111000; 
				p1_o=7'b0111000; 
				p1_t=7'b0111000; 
				p1_h=7'b0111000;
			end
			else begin
				p2_o=p2_1;
				p2_t=p2_2; 
				p2_h=p2_3; 
				p1_o=p1_1; 
				p1_t=p1_2; 
				p1_h=p1_3;
			end
		end
	
	//abc U7(.print(prints),.hex0(p2_o),.hex1(p2_t),.hex2(p2_h),.hex3(p1_o),.hex4(p1_t),.hex5(p1_h));
	
		
endmodule

module game2(clk, rst, pb, h_1p, t_1p, o_1p, h_2p, t_2p, o_2p);
	input clk, rst, pb;
	output [6:0] h_1p, t_1p, o_1p, h_2p, t_2p, o_2p;
	
	reg [6:0] h_1p, t_1p, o_1p, h_2p, t_2p, o_2p;
	reg pb1, pb2;
	reg [3:0] state, nstate;
	reg [22:0] counter;
	reg clk1;
	wire [6:0] h1, t1, o1, h2, t2, o2;
	wire [3:0] hun1, ten1, one1, hun2, ten2, one2;
	wire [11:0] p1, p2;
	
	
	//delay clock 1
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			counter <= 0;
			clk1 = 0;
		end
		else if(counter==5000000)begin
			counter <=0;
			clk1 = ~clk1;
		end
		else 
			counter <= counter + 1;
	end
	
	always@(negedge rst or negedge pb) begin
		if(~rst)
			state = 0;
		else if(state==4'd9)
			state = 4'd9;
		else if(~pb)
			state = state + 1;
		else 
			state = state;
	end
	
	always@(posedge clk1 or negedge rst) begin
		if(~rst)
			nstate = 0;
		else if(nstate==4'd6)
			nstate = 4'd6;
		else if(nstate>=4'd1)
			nstate = nstate + 1;
		else if(state==4'd9)
				nstate = 4'd1;
	end
	
	always@(posedge clk) begin
		if(state==0)begin
			pb1 = 0;
			pb2 = 0;
		end
		else if(state==4'd1 || state==4'd2 || state==4'd3 || state==4'd4) begin
			pb1 = pb;
			pb2 = 0;
		end	
		else if(state==4'd5 || state==4'd6 || state==4'd7 || state==4'd8)begin
			pb1 = 0;
			pb2 = pb;
		end
		else begin
			pb1 = 0;
			pb2 = 0;
		end
	end
	
	always@(posedge clk) begin
		if(state==0)begin
			h_1p = 7'b1111111;
			t_1p = 7'b1111111;
			o_1p = 7'b1111111;
			h_2p = 7'b1111111;
			t_2p = 7'b1111111;
			o_2p = 7'b1111111;
		end
		else if(nstate==4'd1 || nstate==4'd3 || nstate==4'd5)begin
			h_1p = 7'b1111111;
			t_1p = 7'b1111111;
			o_1p = 7'b1111111;
			h_2p = 7'b1111111;
			t_2p = 7'b1111111;
			o_2p = 7'b1111111;
		end
		else if(nstate==3'd6)begin
			h_1p = 7'b1111111;
			t_1p = 7'b1111111;
			
			t_2p = 7'b1111111;
			o_2p = 7'b1111111;
			if(p1>p2) begin
				o_1p = 7'b1111001;
				h_2p = 7'b0001100;
			end
			else if(p1<p2) begin
				o_1p = 7'b0100100;
				h_2p = 7'b0001100;
			end
			else begin
				o_1p = 7'b0111111;
				h_2p = 7'b0111111;
			end
		end
		else begin
			h_1p = h1;
			t_1p = t1;
			o_1p = o1;
			h_2p = h2;
			t_2p = t2;
			o_2p = o2;
		end
		
	end
	
	
	number U7(.clk(clk), .rst(rst), .pb(pb1), .hundred(hun1), .ten(ten1), .one(one1));
	number U8(.clk(clk), .rst(rst), .pb(pb2), .hundred(hun2), .ten(ten2), .one(one2));
	
	
	bcd U1(.binary(one1),  .seg1(o1));
	bcd U2(.binary(ten1),  .seg1(t1));
	bcd U3(.binary(hun1),  .seg1(h1));
	bcd U4(.binary(one2),  .seg1(o2));
	bcd U5(.binary(ten2),  .seg1(t2));
	bcd U6(.binary(hun2),  .seg1(h2));
	
	assign p1 =hun1*100 + ten1*10 + one1;
	assign p2 =hun2*100 + ten2*10 + one2;
	/*
	bcd U9(.binary(p1), .seg3(h1), .seg2(t1), .seg1(o1));
	bcd U10(.binary(p2), .seg3(h2), .seg2(t2), .seg1(o2));
	*/
endmodule



module number(clk, rst, pb, hundred, ten, one);
	input clk, rst, pb;
	output [3:0] one, ten, hundred;
	
	reg clk1, clk2, clk3;
	reg [22:0] counter1, counter2, counter3;
	wire [3:0] one, ten, hundred;
	reg stop;
	
	reg pb1, pb2, pb3;
	reg [2:0] state;

//delay clock 1
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			counter1 <= 0;
			clk1 = 0;
		end
		else if(counter1==500000)begin
			counter1 <=0;
			clk1 = ~clk1;
		end
		else 
			counter1 <= counter1 + 1;
	end
	
//delay clock 2
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			counter2 <= 0;
			clk2 = 0;
		end
		else if(counter2==250000)begin
			counter2 <=0;
			clk2 = ~clk2;
		end
		else 
			counter2 <= counter2 + 1;
	end

	//delay clock 3
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			counter3 <= 0;
			clk3 = 0;
		end
		else if(counter3==100000)begin
			counter3 <=0;
			clk3 = ~clk3;
		end
		else 
			counter3 <= counter3 + 1;
	end

	
	always@(negedge rst or negedge pb) begin
		if(~rst)
			state = 0;
		else if(state==3'd5)
			state = 3'd5;
		else if(~pb)
			state = state + 1;
		else 
			state = state;
	end
	
	always@(posedge clk) begin
		if(state==0)begin
			pb1 = 0;
			pb2 = 0;
			pb3 = 0;
		end
		else if(state==3'd1) begin
			pb1 = pb;
			pb2 = 0;
			pb3 = 0;
		end	
		else if(state==3'd2)begin
			pb1 = 0;
			pb2 = pb;
			pb3 = 0;
		end
		else if(state==3'd3)begin
			pb1 = 0;
			pb2 = 0;
			pb3 = pb;
		end
		else begin
			pb1 = 0;
			pb2 = 0;
			pb3 = 0;
		end
	end
	
	get U4(.clk(clk1), .rst(rst), .pb(pb1), .num(one));
	get U5(.clk(clk2), .rst(rst), .pb(pb2), .num(ten));
	get U6(.clk(clk3), .rst(rst), .pb(pb3), .num(hundred));
	
	
	
endmodule


module get(clk, rst, pb, num);
	input clk, rst, pb;
	output [3:0] num;

	reg [3:0] num;
	reg stop;


	
	always@(negedge rst or negedge pb)begin
		if(~rst)
			stop = 0;
		else if(pb==0)
			stop = ~stop;
		else 
			stop = stop;
	end
	
	
	always@(posedge clk or negedge rst)begin
		if(rst==0) begin
			num = 0;
		end
		else if(stop==1) begin
			num = num;
		end
		else if(num==4'd9) begin
			num = 0;
		end
		else
			num = num + 1;
	
	end
	
	
endmodule


module bcd(binary, seg3, seg2, seg1);
	input [11:0] binary;
	output [6:0] seg1, seg2, seg3;
	reg [6:0] seg1, seg2, seg3;
	
	reg [3:0] hundreds;
	reg [3:0] tens;
	reg [3:0] ones;
 
	integer i;
	always@(binary)
	begin
 		hundreds = 4'b0;
 		tens = 0;
 		ones = 0;
 
 		for(i=10; i>=0; i=i-1)
 		begin
 			if(hundreds >= 5)
 				hundreds = hundreds + 3;
 			if(tens >=5)
 				tens = tens + 3;
 			if(ones >=5)
 				ones = ones + 3;
 
 			hundreds = hundreds <<1;
 			hundreds[0] = tens[3];
 			tens = tens <<1;
 			tens[0] = ones[3];
 			ones = ones <<1;
 			ones[0] = binary[i];
 		end
	end
	
 	always@(hundreds)begin
 		case(hundreds)
 			4'b0000:	seg3 = 7'b1000000;//0
 			4'b0001:	seg3 = 7'b1111001;//1
 			4'b0010:	seg3 = 7'b0100100;//2	
 			4'b0011:	seg3 = 7'b0110000;//3	
 			4'b0100:	seg3 = 7'b0011001;//4	
 			4'b0101:	seg3 = 7'b0010010;//5	
 			4'b0110:	seg3 = 7'b0000010;//6 
 			4'b0111:	seg3 = 7'b1111000;//7	
 			4'b1000:	seg3 = 7'b0000000;//8
 			4'b1001:	seg3 = 7'b0011000;//9
 			default: 	seg3 = 7'b1111111;//all blind
 		endcase
	end
	always@(tens)begin
 		case(tens)
 			  4'b0000:	seg2 = 7'b1000000;//0
 			  4'b0001:	seg2 = 7'b1111001;//1
 			  4'b0010:	seg2 = 7'b0100100;//2	
 			  4'b0011:	seg2 = 7'b0110000;//3	
 			  4'b0100:	seg2 = 7'b0011001;//4	
 			  4'b0101:	seg2 = 7'b0010010;//5	
 			  4'b0110:	seg2 = 7'b0000010;//6 
 			  4'b0111:	seg2 = 7'b1111000;//7	
 			  4'b1000:	seg2 = 7'b0000000;//8
 			  4'b1001:	seg2 = 7'b0011000;//9
 			  default:	seg2 = 7'b1111111;//all blind
 		endcase
	end
	always@(ones)begin
 		case(ones)
			4'b0000:	seg1 = 7'b1000000;//0
			4'b0001:	seg1 = 7'b1111001;//1
 			4'b0010:	seg1 = 7'b0100100;//2	
 			4'b0011:	seg1 = 7'b0110000;//3	
 			4'b0100:	seg1 = 7'b0011001;//4	
 			4'b0101:	seg1 = 7'b0010010;//5	
 			4'b0110:	seg1 = 7'b0000010;//6 
 			4'b0111:	seg1 = 7'b1111000;//7	 
 			4'b1000:	seg1 = 7'b0000000;//8
 			4'b1001:	seg1 = 7'b0011000;//9
 			default: 	seg1 = 7'b1111111;//all blind
 		endcase
	end	
endmodule

/*module abc(print,hex0,hex1,hex2,hex3,hex4,hex5);
	input print;
	output[6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	
	
	if(print<2)begin
		if(print==1)begin
			hex0=7'b1111000; 
			hex1=7'b0000001; 
			hex2=7'b0001111;
			hex3=7'b1111111; 
			hex4=7'b0001001; 
			hex5=7'b1000110;
		end
		
		else begin 
			hex0=7'b0111000; 
			hex1=7'b0111000; 
			hex2=7'b0111000; 
			hex3=7'b0111000; 
			hex4=7'b0111000; 
			hex5=7'b0111000;
		end
	end
	
endmodule
*/