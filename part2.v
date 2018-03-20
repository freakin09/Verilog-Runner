// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable, ld_x, ld_y, ld_c;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	 datapath d0(ld_x, ld_y, ld_c, SW[9:7], SW[6:0], CLOCK_50, KEY[0], enable, colour, x, y);
	 

    // Instansiate FSM control
         control c0(~KEY[3], KEY[0], ~KEY[1], CLOCK_50, writeEn, ld_x, ld_y, ld_c, enable);
    
endmodule

module datapath (colour, data_in1, data_in2, clock, reset_n, enable, colour_out, x, y);
	input reset_n, enable, clock;
	input [7:0] data_in1, data_in2;
	input [2:0] colour;
	output [2:0] colour_out;
	output reg [7:0] x;
	output reg [7:0] y;
	
	reg [7:0] x1, x2;
	reg [2:0] clr;
	
	wire [3:0] c4;
	
	wire [1:0] sel;
	wire [7:0] cselena;
	wire enable_2;

	always @(posedge clock) begin
		if(!reset_n) begin
			x1 <=  8'b0;
			x2 <=  8'b0;
			clr <= 3'b0; 
		end
	
		else begin
			x1 <= data_in1;
			x2 <= data_in2;
			clr <= colour;
		end	
	end 
	

	
	//select the step to draw differnt thing.
	rate_counter1 rc1(clock,reset_n,enable,cselena);
	assign enable_2 = (cselena ==  8'b00000000) ? 1 : 0;
	counter2 msel(clock,reset_n,enable_2,sel);
		
	counter m3(clock,reset_n,enable,c4);//for draw block

	assign colour_out = clr;
	
	always @(*)begin
		case(sel)
		2'b00: begin 
				x = x1 +  c4[1:0] ;
				y = 8'b01110100+ c4[3:2] ;
				end
		2'b01: begin
				x = x2 +  c4[1:0] ;
				y = 8'b01110100+ c4[3:2] ;
				end
		2'b10: begin
				x =  cselena;
				y = 8'b01111000;
			   end
		2'b11: begin
				x =  cselena;
				y = 8'b01111000;
			   end
		endcase
	end

endmodule

module datapath_move(colour, clock, reset_n, enable, colour_out, x, y);
	input clock, reset_n, enable;
	input [2:0] colour;
	
	output  [2:0] colour_out;
	output [7:0] x, y;
	
	wire [2:0] colour_go;
	
	wire enable_f, enable_x;
//	wire [4:0] do;
	wire [19:0] do;
	wire [3:0] fo;
	
	wire [7:0] a, b;
	wire [7:0] q1, q2;
	
//	delay_counter2 dc2(clock,reset_n,enable,do);
	delay_counter dc(clock,reset_n,enable,do);
	assign enable_f = (do == 20'b0) ? 1 : 0;
//   assign enable_f = (do == 5'b0) ? 1 : 0;
	frame_counter fc(clock,reset_n,enable_f,fo); 
	assign enable_x = (fo == 4'b1111) ? 1 : 0;
	
	random_distance rd(clock,reset_n,enable, a, b);
	x_counter xc1(enable_x, clock, reset_n, a, enable, q1);
	x_counter xc2(enable_x, clock, reset_n, b, enable, q2);
	
	assign colour_go = (fo == 4'b1111) ? 3'b0: 3'b111;
	
	datapath dp(colour_go, q1, q2, clock, reset_n, enable, colour_out, x, y);
	
endmodule


module counter(clk, reset_n, enable, o);
	input clk, reset_n, enable;
	output reg [3:0] o;

	always @(posedge clk) begin
		if (!reset_n) 
			o <= 4'b0;
		else if (enable)
		begin
		  if (o == 4'b1111)
			o <= 4'b0;
		  else
			o <= o + 1'b1;
		end		
	end	

endmodule

module counter2(clk, reset_n, enable, o);
	input clk, reset_n, enable;
	output reg [1:0] o;

	always @(posedge clk) begin
		if (!reset_n) 
			o <= 2'b0;
		else if (enable)
		begin
		  if (o == 2'b11)
			o <= 2'b0;
		  else
			o <= o + 1'b1;
		end		
	end	

endmodule


module rate_counter1(clock,reset_n,enable,q);
		input clock;
		input reset_n;
		input enable;
		output reg [7:0] q;
		
		always @(posedge clock)
		begin
			if(reset_n == 1'b0)
				q <= 8'b11111111;
			else if(enable ==1'b1)
			begin
			   if ( q == 8'b00000000 )
					q <= 8'b11111111;
				else
					q <= q - 1'b1;
			end
		end
endmodule	

module control(go, reset_n, draw, clk, plot, ld_x, ld_y, ld_c, enable);
	input go, reset_n, clk, draw;
	output reg ld_x, ld_y, ld_c, enable, plot;
	
	reg [2:0] current_state, next_state;
	
	localparam S_LOAD_X = 3'd0,
		   S_LOAD_X_WAIT = 3'd1,
		   S_LOAD_Y = 3'd2;
	
	
	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state =  S_LOAD_Y;
		default: next_state = S_LOAD_X;
		endcase
	end
	
	always @(*)
	begin: enable_signals
	ld_c = 1'b0;
	enable = 1'b0;
	plot = 1'b0;

	case (current_state)
		S_LOAD_Y: begin
			ld_c = 1'b1;
			enable = 1'b1;
			plot = 1'b1;
		end
		endcase
	end
	


	always @(posedge clk)
		begin
			if(!reset_n)
				current_state <= S_LOAD_X;
			else
				current_state <= next_state;
		end
	
endmodule

 
 module frame_counter(clock,reset_n,enable,q); 
 	input clock,reset_n,enable; 
 	output reg [3:0] q; 
 	 
 	always @(posedge clock) 
 	begin 
 		if(reset_n == 1'b0) 
 			q <= 4'b0000; 
 		else if(enable == 1'b1) 
 		begin 
 		  if(q == 4'b1111) 
 			  q <= 4'b0000; 
 		  else 
 			  q <= q + 1'b1; 
 		end 
    end 
 endmodule 
 
 
 module delay_counter(clock,reset_n,enable,q); 
 		input clock; 
 		input reset_n; 
 		input enable; 
 		output reg [19:0] q; 
 		 
 		always @(posedge clock) 
 		begin 
 			if(reset_n == 1'b0) 
 				q <= 20'b11001110111001100001; 
 			else if(enable ==1'b1) 
 			begin 
 			   if ( q == 20'd0 ) 
 					q <= 20'b11001110111001100001; 
 				else 
 					q <= q - 1'b1; 
 			end 
 		end 
 endmodule 
 
 module delay_counter2(clock,reset_n,enable,q); 
 		input clock; 
 		input reset_n; 
 		input enable; 
 		output reg [4:0] q; 
 		 
 		always @(posedge clock) 
 		begin 
 			if(reset_n == 1'b0) 
 				q <= 5'b10000; 
 			else if(enable ==1'b1) 
 			begin 
 			   if ( q == 5'd0 ) 
 					q <= 5'b10000; 
 				else 
 					q <= q - 1'b1; 
 			end 
 		end 
 endmodule 
 
module x_counter(enable_x, clock, reset_n, distance, enable,q); 
 	input clock,reset_n,enable, enable_x; 
	input [7:0] distance;
 	output reg [7:0] q; 
	
	always @(posedge clock)
			begin
				if(!reset_n)
					q <= 8'b10100000;
			end
 	
 	always @(negedge enable_x) 
 	begin 
 		if(reset_n == 1'b0) begin
 			q <= 8'b10100000;
			end
 		else if(enable == 1'b1) 
 		begin 
 		  if(q == 8'b00000000) 
 			  q <= distance; 
 		  else 
 			  q <= q - 1'b1; 
 		end 
    end 
 endmodule 
 
 
module random_distance(clock,reset_n,enable, a, b); 
 	input clock,reset_n,enable; 
 	reg [1:0] q;
	output reg [7:0] a, b;
 	 
 	always @(posedge clock) 
 	begin 
 		if(reset_n == 1'b0) 
 			q <= 2'b11; 
 		else if(enable == 1'b1) 
 		begin 
 		  if(q == 2'b0) begin
 			  q <= 2'b11;
			  a <= $urandom%10 + 8'd160; 
           b <= $urandom%10 + 8'd160;
			end  
 		  else 
 			  q <= q - 1'b1; 
 		end 
    end 
 endmodule 




