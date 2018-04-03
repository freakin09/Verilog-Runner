module verilog_runner
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
		,
		HEX0,HEX1
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
	
	output [6:0] HEX0, HEX1;
		
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable;
	
	wire [6:0] hex0, hex1;
	
	//for colour
	wire [2:0] colour_got, colour_bar;

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
	 datapath_move dm(SW[1:0], ~KEY[1], colour_got, colour_bar, CLOCK_50, KEY[0], enable, colour, x, y, HEX0, HEX1);

    // Instansiate FSM control
    control c0(~KEY[3], KEY[0], KEY[2], CLOCK_50, writeEn, enable, colour_got, colour_bar);
    
endmodule


module score_counter(clk, reset_n, enable, score);
		input clk, reset_n, enable;
		output reg [3:0] score;
		
		always @(clk)
		if (!reset_n)
			score <= 4'b0;
		else if (enable)begin
			if (score == 4'b1001)
				score <= 4'b0;
			else
				score <= score + 1'b1;
		end
endmodule


// for drawing the block
module block_counter(clk, reset_n, enable, o);
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


// for different part of object
// count from 0 to 5, represent 6 objects.
module object_counter(clk, reset_n, enable, o);
	input clk, reset_n, enable;
	output reg [2:0] o;

	always @(posedge clk) begin
		if (!reset_n) 
			o <= 3'b0;
		else if (enable)
		begin
		  if (o == 3'b101)
			o <= 3'b0;
		  else
			o <= o + 1'b1;
		end		
	end	

endmodule

// count the duration time for different objects
module duration_counter(clock,reset_n,enable,q);
		input clock;
		input reset_n;
		input enable;
		output reg [7:0] q;
		
		always @(posedge clock)
		begin
			if(reset_n == 1'b0)
				q <= 8'b10100000;
			else if(enable ==1'b1)
			begin
			   if ( q == 8'b00000000 )
					q <= 8'b10100000;
				else
					q <= q - 1'b1;
			end
		end
endmodule	

 // count the frames needed for a move
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
 
 
 //count the time needed for a frame
 module delay_counter(clock,reset_n,enable, load_value, q); 
 		input clock; 
 		input reset_n; 
 		input enable;
		input [19:0] load_value;
 		output reg [19:0] q; 
 		 
 		always @(posedge clock) 
 		begin 
 			if(reset_n == 1'b0) 
 				q <= load_value; 
 			else if(enable ==1'b1) 
 			begin 
 			   if ( q == 20'd0 ) 
 					q <= load_value; 
 				else 
 					q <= q - 1'b1; 
 			end 
 		end 
 endmodule 
 
// count the x-coordinate for the moving_block, distance will randomly be assighed different
// values.
module x_counter(enable_x, reset_n, distance, enable,q, collision); 
 	input reset_n,enable, enable_x, collision; 
	input [7:0] distance;
 	output reg [7:0] q; 
 	
 	always @(negedge enable_x or negedge reset_n)
	begin
	if(!reset_n)
					q <= 8'b10100000;

	else if(enable == 1'b1 && !collision) 
	begin
 		  if(q == 8'b00000000) 
 			  q <= distance; 
 		  else 
 			  q <= q - 1'b1;
			 end 
 		end  
		
 endmodule 
 
 // the datapath for drawing the objects
 module datapath (colour, colour_bar, data_in1, data_in2, data_in3, data_in4,
						data_in5, clock, reset_n, high_low,enable, colour_out, x, y);
	input reset_n, enable, clock;
	input [7:0] data_in1, data_in2, data_in3, data_in4; //x coordinates for 4 blocks
	input [6:0] data_in5; //person_y
	input [2:0] colour, colour_bar;
	output reg [2:0] colour_out;
	output reg [7:0] x;
	output reg [6:0] y;
	
	//for height
	input high_low;
	
	reg [7:0] x1, x2, x3, x4;
	reg [6:0] x5;//x5 for person
	reg [2:0] clr;
	
	// for block drawing
	wire [3:0] c4;
	
	wire [2:0] sel;//sel for choosing which part to draw
	wire [7:0] enable_sel;// to enable the counter for sel
	wire enable_object; // to enable the object counter to continue draw next object 
	
	//for height
	wire [3:0] height1, height2, height3, height4;
	
	//for person colour
	wire [2:0] clrPerson;

	always @(posedge clock) begin
		if(!reset_n) begin
			x1 <=  8'b0;
			x2 <=  8'b0;
			x3 <=  8'b0;
			x4 <=  8'b0;
			x5 <=  7'b0;
			clr <= 3'b0; 
		end
	
		else begin
			x1 <= data_in1;
			x2 <= data_in2;
			x3 <= data_in3;
			x4 <= data_in4;
			x5 <= data_in5;
			clr <= colour;
		end	
	end 
	
	
	
	//select the step to draw differnt thing.
    //TODO : Why do we need duration counter ?
	duration_counter dc(clock,reset_n,enable,enable_sel);
	assign enable_object = (enable_sel ==  8'b00000000) ? 1 : 0;
	object_counter oc(clock,reset_n,enable_2,sel); //TODO : did you mean enable object ?
		
	block_counter bc(clock,reset_n,enable,c4);//for draw block
	
	
	
	//for height1-5 determine whether the block is high or on the ground
	assign height1 = (high_low) ? 4'b1010 : 4'b0; 
	assign height2 = (high_low) ? 4'b1010 : 4'b0; 
	assign height3 = (high_low) ? 4'b1010 : 4'b0; 
	assign height4 = (high_low) ? 4'b1010 : 4'b0; 
	

//colour for 'person'
	assign clrPerson = (clr == 3'b000) ? 3'b000 : 3'b110;
	
	always @(*)begin
		case(sel)
		3'b000: begin 
                //ground
				colour_out = colour_bar;
				x =  enable_sel;
				y = 7'b0111000;
				end
		3'b001: begin
                //blcok1
				colour_out = clr;
				x = x1 -  c4[1:0] ;
				y = 7'b0110100 + c4[3:2] - height1;
				end
		3'b010: begin
				colour_out = clr;
				x = x2 -  c4[1:0] ;
				y = 7'b0110100 + c4[3:2] - height2;
			   end
		3'b011: begin
				colour_out = clr;
				x = x3 -  c4[1:0] ;
				y = 7'b0110100 + c4[3:2] - height3;
			   end
		3'b100: begin
                //block4
				colour_out = clr;
				x = x4 -  c4[1:0] ;
				y = 7'b0110100 + c4[3:2] - height4;
			   end
		3'b101: begin
                //person
				colour_out = clrPerson;
				x = 8'b00101000 +  c4[1:0] ;
				y = x5 + c4[3:2] ;
				end
		endcase
	end

endmodule



//datapath which set up values for different objects
module datapath_move(frequency, jump, colour, colour_bar, clock, reset_n, enable, colour_out, x, y, hex0, hex1);
	input clock, reset_n, enable, jump;
	input [2:0] colour, colour_bar;
	input [1:0] frequency;
	
	output  [2:0] colour_out;
	output [7:0] x;
	output [6:0] y;
	output [6:0] hex0, hex1;
	
	wire [2:0] colour_go;
	
	wire enable_x;
	wire [19:0] dout;//delay_counter output
	wire [3:0] fo;// frame_counter output
	
	wire [7:0] a, b, c, d;
	wire [7:0] q1, q2, q3, q4;//q1-4 for blocks
	wire [6:0] q5;//q5 for person object
	
	//for randoom
	wire [7:0] rand_num;
	
	//for height
	wire enable_h1, enable_h2, enable_h3, enable_h4;
	
	//for score record
	wire clock_score, clock_sc2, clock_sc3;
	wire [3:0] score1, score2, score3;
	
	//for speed
	wire [19:0] slowout, medout, quickout;

	localparam GROUND = 8'b00110100;
	localparam PERSON_X = 8'b00101000;
        localparam WIDTH = 4'd4;
        localparam PERSON_HEIGHT = 4'd4;
	
	reg enable_f;
	//speed
	delay_counter slow(clock,reset_n,enable,20'b10011101011011000000, slowout);
	delay_counter med(clock,reset_n,enable,20'b01001110101101100000, medout);
	delay_counter quick(clock,reset_n,enable, 20'b00100111010110110000, quickout);
	always @(*)begin
		case(frequency)
			2'b00:enable_f = (slowout == 0)? 1 : 0;
			2'b01:enable_f = (medout == 0)? 1 : 0;
			2'b10:enable_f = (quickout == 0)? 1 : 0;
		default: enable_f = (medout == 0)? 1 : 0;
		endcase
	end
	
	//count the time need to change the x-coordinate
//	delay_counter dc(clock,reset_n,enable,dout);
//	assign enable_f = (dout == 20'b0) ? 1 : 0;
	frame_counter fc(clock,reset_n,enable_f,fo); 
	assign enable_x = (fo == 4'b1111) ? 1 : 0;
	
	//random number generater
	RanGen rg( reset_n, clock, 8'b10101010, rand_num);
	
	assign a = 8'b10100000  + rand_num[2:0] ;
	assign b = 8'b10101110  + rand_num[2:0];
	assign c = 8'b10111100  + rand_num[2:0];
	assign d = 8'b11001010  + rand_num[2:0];

	wire collision1, collision2, collision3, collision4, collision;

//	random_distance rd(clock,reset_n,enable, a, b);
	x_counter xc1(enable_x,  reset_n, a, enable, q1, collision);
	x_counter xc2(enable_x,  reset_n, b, enable, q2, collision);
	x_counter xc3(enable_x,  reset_n, c, enable, q3, collision);
	x_counter xc4(enable_x,  reset_n, d, enable, q4, collision);
	movePlayer mp(enable_x, reset_n, jump, q5);


//      detect collision
	detectCollision dc0(reset_n, PERSON_X, q5, WIDTH, PERSON_HEIGHT,
                        q1, GROUND, WIDTH, WIDTH, collision1);

	detectCollision dc1(reset_n, PERSON_X, q5, WIDTH, PERSON_HEIGHT,
                        q2, GROUND, WIDTH, WIDTH, collision2);

	detectCollision dc2(reset_n, PERSON_X, q5, WIDTH, PERSON_HEIGHT,
                        q3, GROUND, WIDTH, WIDTH, collision3);

	detectCollision dc3(reset_n, PERSON_X, q5, WIDTH, PERSON_HEIGHT,
                        q4, GROUND, WIDTH, WIDTH, collision4);

        //set collision hight if collides with any block
        assign collision = (collision1 || collision2 || collision3 || collision4) ? 1’b1 : 1’b0;

	
	//for local parameter x-coordinate for the person object
	localparam person_x = 8'b00100100;
	
	//enable score counter
	assign clock_score = ((q1 == 8'b00100100) || (q2 == 8'b00100100) || 
		(q3 == 8'b00100100) || (q4 == 8'b00100100)) ? 1'b1 : 1'b0;
	//for recording the score
	score_counter sc1(clock_score, reset_n, enable, score1);
	assign clock_sc2 = (score1 == 4'b1001) ? 1'b1: 1'b0;
	score_counter sc2(clock_sc2, reset_n, enable, score2);
	assign clock_sc3 = (score1 == 4'b1001) ? 1'b1: 1'b0;
	score_counter sc3(clock_sc3, reset_n, enable, score3);
	
	//hex_play
	hex_decoder H0(
        .hex_digit(score1[3:0]), 
        .segments(hex0)
        );
        
    hex_decoder H1(
        .hex_digit(score2[3:0]), 
        .segments(hex1)
        );
	
	//random_hight
	reg high_low; //high_low determine the height
	assign enable_h1 = (q1 == 1'b0) ? 1'b1 : 1'b0;
	assign enable_h2 = (q2 == 1'b0) ? 1'b1 : 1'b0;
	assign enable_h3 = (q3 == 1'b0) ? 1'b1 : 1'b0;
	assign enable_h4 = (q4 == 1'b0) ? 1'b1 : 1'b0;

	
	always @(negedge enable_h1,negedge enable_h2, negedge enable_h3,negedge enable_h4
					,negedge reset_n)
		begin
			if(!reset_n)
				high_low <= 1'b0;
			else 
				high_low <= rand_num % 2;
		end
	
	wire [2:0] main_colour;
	assign main_colour = (collision == 1'b1) ? 3'b100 : colour;
	
	assign colour_go = (fo == 4'b1111) ? 3'b0: main_colour;
	
	datapath dp(colour_go, colour_bar, q1, q2, q3, q4, q5,
				clock, reset_n, high_low, enable, colour_out, x, y);
	
endmodule

module control(go, reset_n, blackout, clk, plot, enable, colour_out, colour_bar);
	input go, reset_n, clk, blackout;
	output reg enable, plot;
	output reg [2:0] colour_out, colour_bar;
	
	reg [2:0] current_state, next_state;
	
	localparam S_LOAD_X = 3'd0,
		   S_LOAD_X_WAIT = 3'd1,
		   S_LOAD_Y = 3'd2,
			S_FIN = 3'd3;
	
	
	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state =  blackout ? S_LOAD_Y : S_FIN;
			S_FIN: next_state = reset_n ? S_FIN : S_LOAD_X;
		default: next_state = S_LOAD_X;
		endcase
	end
	
	always @(*)
	begin: enable_signals
	enable = 1'b0;
	plot = 1'b0;
	colour_out = 3'b000;
	colour_bar = 3'b000;

	case (current_state)
		S_LOAD_Y: begin
			enable = 1'b1;
			plot = 1'b1;
			colour_out = 3'b111;
			colour_bar = 3'b111;
		end
		S_FIN: begin
			enable = 1'b1;
			plot = 1'b1;
			colour_out = 3'b000;
			colour_bar = 3'b000;
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
 
 module RanGen(
    input               rst_n,    /*rst_n is necessary to prevet locking up*/
    input               clk,      /*clock signal*/
//    input               load,     /*load seed to rand_num,active high */
    input      [7:0]    seed,     
    output reg [7:0]    rand_num  /*random number output*/
);


		always@(posedge clk or negedge rst_n)
		begin
			 if(!rst_n)
				  rand_num    <= seed;
		//    else if(load)
		//        rand_num <=seed;    /*load the initial value when load is active*/
			 else
				  begin
						rand_num[0] <= rand_num[7];
						rand_num[1] <= rand_num[0];
						rand_num[2] <= rand_num[1];
						rand_num[3] <= rand_num[2];
						rand_num[4] <= rand_num[3]^rand_num[7];
						rand_num[5] <= rand_num[4]^rand_num[7];
						rand_num[6] <= rand_num[5]^rand_num[7];
						rand_num[7] <= rand_num[6];
				  end
						
		end
endmodule

module movePlayer(enable_x, reset_n, jump, player_h);
	input enable_x, reset_n, jump;
	output reg [6:0] player_h;


	always @(negedge enable_x or negedge reset_n)
		begin
		if(!reset_n)
			player_h <= 7'b0110100;
		else if(jump)
		begin
			player_h <= player_h - 1'b1;
		end
		else if(player_h < 7'b0110100)
			player_h <= player_h + 1'b1;
		else 
			player_h <= 7'b0110100;
		end
endmodule


module detectCollision(reset_n, runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);
   
	 input reset_n;
    
    input [7:0] runner_x, block_x;
    input [6:0] runner_y, block_y;
	 input [3:0] block_width,block_height, runner_width, runner_height;
    output reg collision;

    always @(*) begin
	if(!reset_n)
            collision <= 1'b0;
        //if collision was already detected then it stays high
        else if(collision == 1'b1)
            collision <= 1'b1;
        // if runner is in touch with block, set collision to high
        else if(runner_x >= block_x && 
           runner_x + runner_width <= block_x + block_width &&
           runner_y >= block_y && 
           runner_y + runner_height <= block_y + block_height)
           
            collision <= 1'b1;

        else
            collision <= 1'b0;

    end


endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

