// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
        HEX0, HEX1, HEX2, HEX3,
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
	wire enable;
	
	//for colour
	wire [2:0] colour_got;

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
	 datapath_move dm(~KEY[1], colour_got, CLOCK_50, KEY[0], enable, colour, x, y);

     // Instansiate FSM control
     control c0(CLOCK_50, KEY[0], ~KEY[3], KEY[2], writeEn,  enable, colour_got);

     wire [7:0] score, high_score;
     count [27:0] count;

     ClockDividor rd25(
        .clock(CLOCK_50),
	.enable(enable),
	.load_v({28'd199999999}),
	.count(count)
	);

     wire slowed_clock;
     assign slowed_clock = (count == 28’d0) ? 1 : 0;

     score_counter sc0(slowed_clock, enable, KEY[0], score, high_score);

     hex_decoder H0(
        .hex_digit(score[3:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(score[7:4]), 
        .segments(HEX1)
        );

     hex_decoder H2(
        .hex_digit(high_score[3:0]), 
        .segments(HEX2)
        );
        
    hex_decoder H3(
        .hex_digit(high_score[7:4]), 
        .segments(HEX3)
        );

     
    
endmodule

// 28 bit counter that counts down from load value to 0 repeatedly 
module ClockDividor(clock, enable, load_v,  count);

    
  input clock, enable;
  input [27:0] load_v;
  output reg [27:0] count;

  // syncronous reset
  always @(posedge clock)
  begin
       if(enable == 1'b1)
          begin 
	      if( count == 0)  // check if  counted down 
	          count <= load_v;
	      else
	          count <= count - 1'b1;

	  end
  end

endmodule


//counter for drawing 4 x 4 squares
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

// 2 bit counter
module counter2bit(clk, reset_n, enable, o);
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

module counter3bit(clk, reset_n, enable, o);
	input clk, reset_n, enable;
	output reg [2:0] o;

	always @(posedge clk) begin
		if (!reset_n) 
			o <= 3'b0;
		else if (enable)
		begin
		  if (o == 3'b100)
			o <= 3'b0;
		  else
			o <= o + 1'b1;
		end		
	end	

endmodule


module rate_counter(clock,reset_n,enable,q);
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

// essentially a 4 bit counter
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
 		output reg [7:0] q; 
 		 
 		always @(posedge clock) 
 		begin 
 			if(reset_n == 1'b0) 
 				q <= 8'b1111_1111; 
 			else if(enable ==1'b1) 
 			begin 
 			   if ( q == 8'd0 ) 
 					q <= 8'b1111_1111; 
 				else 
 					q <= q - 1'b1; 
 			end 
 		end 
endmodule 
 
module x_counter(clock, reset_n, distance, enable,q); 
 	input reset_n,enable, clock; 
	input [7:0] distance;
 	output reg [7:0] q; 
	
 	always @(negedge clock or negedge reset_n)
	begin
	if(!reset_n)
					q <= 8'b10100000;

	else if(enable == 1'b1) 
	begin
 		  if(q == 8'b00000000) 
 			  q <= distance; 
 		  else 
 			  q <= q - 1'b1;
			 end 
 		end  
		
 endmodule 
 
 module datapath (colour, data_box1, data_box2, data_box3, clock, reset_n, high_low,enable,collision, colour_out, x, y);
	input reset_n, enable, clock;
	input [7:0] data_box1, data_box2, data_box3;
	input [2:0] colour;
	output reg [2:0] colour_out;
	output reg [7:0] x;
	output reg [7:0] y;

    wire collision1, collision2, collision3;
	
	//for height above ground
	input high_low;
	
	reg [7:0] block_1_x, block_2_x, block_3_x;
	reg [2:0] clr;
	
	wire [3:0] c4;
	
	wire [2:0] state;
	wire [7:0] frames;
	wire draw_enable;
	
	//for height
	wire [1:0] c2bit;
	wire enable_height;
	wire [3:0] height_above_ground;
	
	//for person colour
	wire [2:0] clrPerson;

    localparam GROUND = 8'b00111000;
    localparam GROUND_COLOUR = 3'b010;
    localparam PERSON_X = 8'b00101000;

	always @(posedge clock) begin
		if(!reset_n) begin
			block_1_x <=  8'b0;
			block_2_x <=  8'b0;
			block_3_x <=  8'b0;
			clr <= 3'b0; 
            collision = 1'b0;
		end
	
		else begin
			block_1_x <= data_box1;
			block_2_x <= data_box2;
			block_3_x <= data_box3;
			clr <= colour;
		end	
	end 
	

	
	//select the step to draw differnt thing.
	rate_counter rc1(clock,reset_n,enable, frames);
	assign draw_enable = (frames ==  8'b00000000) ? 1 : 0;
    

	counter3bit state_counter(clock,reset_n, draw_enable, state);
		
	counter m3(clock,reset_n,enable,c4);//for draw block
    
    localparam HEIGHT_ABOVE = 4'b1010;

	//for height
	assign height_above_ground = (high_low) ? HEIGHT_ABOVE : 4'b0; 
	

    module detectCollision(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);

    localparam WIDTH = 4'd4;
    localparam PERSON_HEIGHT = 4'd4;

	detectCollision dc0(PERSON_X, GROUND, WIDTH, PERSION_HEIGHT,
                        q1, GROUND, WIDTH, WITH, collision1);

	
	detectCollision dc1(PERSON_X, GROUND, WIDTH, PERSION_HEIGHT,
                        q2, GROUND, WIDTH, WITH, collision2);

	detectCollision dc2(PERSON_X, GROUND, WIDTH, PERSION_HEIGHT,
                        q3, GROUND, WIDTH, WITH, collision3);
	
    //colour for 'person'
    //assign black if clr is black
	assign clrPerson = (clr == 3'b000) ? 3'b000 : 3'b110;
	
	always @(*)begin
       //if collided, chane colour and stop moving
	   if(collision1 || collision2 || collision3) begin
		    colour_out = 3'b100;
	    end
		else begin
	        case(state)
	       	3'b000: begin 
                    // GROUND
	       			colour_out = GROUND_COLOUR;
	       			x =  cselena;
	       			y = GROUND;
	       			end
	       	3'b001: begin
                    //block_1
	       			colour_out = clr;
	       			x = block_1_x +  c4[1:0] ;
	       			y = GROUND - c4[3:2] ;
	       			end
	       	3'b010: begin
                    //block_2
	       			colour_out = clr;
	       			x = block_2_x -  c4[1:0] ;
	       			y = GROUND - c4[3:2] - height_above_ground;
	       		   end
	       	3'b011: begin
                    //block_3
	       			colour_out = clr;
         			x = block_3_x +  c4[1:0] ;
	       			y = GROUND - c4[3:2] ;
	       		   end
	       	3'b100: begin
                    //Person
	       			colour_out = clrPerson;
	       			x = PERSON_X +  c4[1:0] ;
	       			y = GROUND - c4[3:2] ;
	       		   end
	       	endcase
		end
	end

endmodule

module datapath_move(jump, colour, clock, reset_n, enable, colour_out, x, y);
	input clock, reset_n, enable, jump;
	input [2:0] colour;
	
	
	output  [2:0] colour_out;
	output [7:0] x, y;
	
	wire [2:0] colour_go;
	
	wire enable_f, enable_x;
	wire [19:0] dout;
	wire [3:0] erase_counter;
	
	wire [7:0] starting_block_1_x, starting_block_2_x, starting_block_3_x;
	wire [7:0] q1, q2, q3;
	
	//for randoom
	wire [7:0] rand_num;
	
	//for height
	wire enable_h2;
	
    localparam GROUND = 8'b00111000;
    localparam PERSON_X = 8'b00101000;
    
    //CHANGED THE COUNT OF DELAY COUNTER    
	delay_counter dc(clock,reset_n,enable,dout);
	assign enable_f = (dout == 8'b0) ? 1 : 0;

	frame_counter fc(clock,reset_n,enable_f,frame_counter); 
	assign enable_x = (frame_counter == 4'b1111) ? 1 : 0;
	
    //erase every 4 clock cycles
	assign colour_go = (frame_counter == 4'b1111) ? 3'b0: colour;
	
    RanGen rg( reset_n, clock, 8'b10101010, rand_num );
	
    localparam STARTING_BLOCK_1_X = 8'b10101111;
    localparam STARTING_BLOCK_2_X = 8'b10100100;
    localparam STARTING_BLOCK_2_X = 8'b10111110;

	assign starting_block1_x = STARTING_BLOCK_1_X + rand_num[2:0];
	assign starting_block2_x = STARTING_BLOCK_1_X + rand_num[2:0];
	assign starting_block3_x = STARTING_BLOCK_2_X + rand_num[2:0];

	
	x_counter xc1(enable_x,  reset_n, starting_block_1_x, enable, q1);
	x_counter xc2(enable_x,  reset_n, starting_block_2_x, enable, q2);
	x_counter xc3(enable_x,  reset_n, starting_block_3_x, enable, q3);
	movePlayer mp(enable_x, reset_n, jump, q3);



	//random_hight
	reg high_low; //high_low determine the height
	assign enable_h2 = ((q2 + 3'b100) == 1'b0) ? 1'b1 : 1'b0;
	always @(negedge enable_h2, negedge reset_n)
		begin
			if(!reset_n)
				high_low <= 1'b0;
			else 
				high_low <= rand_num[0];
		end
	
	
	datapath dp(colour_go, q1, q2, q3, clock, reset_n, high_low, enable, colour_out, x, y);
	
endmodule

//changes state from ready to black out
module control(clock, go, reset_n, blackout, plot, enable,  colour_out);
	input go, reset_n, clk, blackout;
    output enable, plot;
	output reg [2:0] colour_out;
	
	reg [2:0] current_state, next_state;
	
	localparam S_STARTING = 2'd0,
               S_DRAW = 2'd1,
               S_BLACK = 2'd2;
		   
	
	
	always @(*)
	begin: state_table
		case (current_state)
			S_START: next_state = go ? S_DRAW : S_START;
			S_DRAW: next_state = blackout ? S_BLACK : S_DRAW;
			S_BLACK: next_state = S_START;
		default: next_state = S_LOAD_X;
		endcase
	end
	
	always @(*)
	begin: enable_signals
        enable = 1'b0;
       	plot = 1'b0;
       	colour_out = 3'b000;

    	case (current_state)
    		S_DRAW: begin
    			enable = 1'b1;
    			plot = 1'b1;
                //default color is white
    			colour_out = 3'b111;
    		end
    		S_BLACK: begin
    			enable = 1'b1;
    			plot = 1'b1;
                //Black colour
    			colour_out = 3'b000;
    		end
    		endcase
	end
	


	always @(posedge clk)
		begin
			if(!reset_n)
				current_state <= S_START;
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
	output reg [7:0] player_h;
	
   localparam GROUND = 8'b00110100;


	always @(negedge enable_x or negedge reset_n)
		begin
		if(!reset_n)
			player_h <= GROUND;
		else if(jump && player_h >= GROUND)
		begin
		       //TODO: make it jump higher
			    player_h <= player_h - 3'd4;
				
		end
		else if(player_h < GROUND)
			player_h <= player_h + 1'b1;
		else 
			player_h <= GROUND;
		end
     
     

endmodule


module detectCollision(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);
   
    
    input [7:0] runner_x, block_x;
    input [6:0] runner_y, block_y;
	input [1:0] block_width,block_height, runner_width, runner_height;
    output reg collision;

    always @(*) begin
        //if collision was already detected then it stays high
        if(collision)
            collision <= 1'b1
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

module scoreCounter(clock, enable, reset_n, score, high_score);

    input clock, enable, reset_n;
    output reg [7:0] score, high_score;

    always @(posedge clock) begin
        if(reset_n)begin
            score <= 8'd0;
            if(high_score < score)
                high_score <= score;        
        end
            
        else if(enable)
            score <= score + 1'b1;
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
