// Part 2 skeleton

module moving_background
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

    // wires to connect datapath and controller
    wire load_ground, load_box1, load_box2, load_box3, load_person, enable;
    // Instansiate datapath
	// datapath d0(...);
    datapath d0(CLOCK_50,KEY[0], enable,load_ground, load_box1, load_box2, load_box3, load_person, x, y, colour);
    // Instansiate FSM control
    // control c0(...);
    control c0(~KEY[3],KEY[0],CLOCK_50,enable,load_ground, load_box1, load_box2, load_box3, load_person,writeEn); 
endmodule

module control(go,reset_n, clock, enable, load_ground, load_box1, load_box2, load_box3, load_person, plot);
	
      input go,reset_n,clock;
		
		output reg enable,load_ground, load_box1,load_box2,load_box3, load_person,plot;
		
		reg [3:0] current_state, next_state;
		
		reg [7:0] line_counter;

		
		localparam    S_LOAD_BOX1        = 4'd0,
                    S_LOAD_BOX1_WAIT   = 4'd1,
						  S_READY1            = 4'd2,
						  
                    S_LOAD_BOX2        = 4'd3,
                    S_LOAD_BOX2_WAIT   = 4'd4,
						  S_READY2            = 4'd5,
						  
						  S_LOAD_BOX3        = 4'd6,
                    S_LOAD_BOX3_WAIT   = 4'd7,
						  S_READY3            = 4'd8,
						  
						  S_LOAD_PERSON        = 4'd9,
                    S_LOAD_PERSON_WAIT   = 4'd10,
						  S_READY4            = 4'd11 ,
						  
						  S_STARTING           = 4'd12,
                    S_LOAD_GROUND              = 4'd13,
                    S_GROUND_WAIT         = 4'd14,
                    S_READY0               = 4'd15;
		
		always@(*)
        begin: state_table 
            case (current_state)
                
                S_STARTING : next_state = go ? S_LOAD_GROUND : S_STARTING; 

                //Draw Ground
                S_LOAD_GROUND:next_state = S_GROUND_WAIT; 
                S_GROUND_WAIT: begin
                                    line_counter = 8'd160; // width of screen
                                    next_state = S_READY0;
												end
                S_READY0: next_state = (line_counter == 8'd0) ? S_LOAD_BOX1: S_READY0;

                //DRAW box1
                S_LOAD_BOX1: next_state =  S_LOAD_BOX1; 
                S_LOAD_BOX1_WAIT: next_state = S_READY1; 
                S_READY1: next_state = S_LOAD_BOX2;

                //DRAW box2
                S_LOAD_BOX2: next_state = S_LOAD_BOX2_WAIT; 
                S_LOAD_BOX2_WAIT: next_state = S_READY2; 
                S_READY2: next_state = S_LOAD_BOX3;


                //DRAW box3
                S_LOAD_BOX3: next_state = S_LOAD_BOX3_WAIT; 
                S_LOAD_BOX3_WAIT: next_state = S_READY3; 
                S_READY3: next_state = S_LOAD_PERSON;
                

                //DRAW person
                S_LOAD_PERSON: next_state = S_LOAD_PERSON_WAIT; 
                S_LOAD_PERSON_WAIT: next_state = S_READY4; 
                S_READY4: next_state = S_LOAD_BOX1;

                default:     next_state = S_LOAD_BOX1;

        endcase
        end 
		
	always@(*)
        begin: enable_signals
            // By default make all our signals 0
	        load_ground = 1'b0;
            load_box1 = 1'b0;
            load_box2 = 1'b0;
            load_box3 = 1'b0;
            load_person = 1'b0;
	    enable = 1'b0;
            plot = 1'b0;
		    
	    case(current_state)

	      	S_LOAD_GROUND_WAIT:begin
	      		load_ground = 1'b1;
	      		end

	      	S_LOAD_BOX1_WAIT:begin
	      		load_box1 = 1'b1;
	      		end
	      	S_LOAD_BOX2_WAIT:begin
	      		load_box2 = 1'b1;
	      		end
	      	S_LOAD_BOX3_WAIT:begin
	      		load_box3 = 1'b1;
	      		end
	      	S_LOAD_PERSON_WAIT:begin
	      		load_person = 1'b1;
	      		end

		S_READY0:begin
		        enable = 1'b1;
	      		plot = 1'b1;
		        end

		S_READY1:begin
		        enable = 1'b1;
	      		plot = 1'b1;
		        end

		S_READY2:begin
		        enable = 1'b1;
	      		plot = 1'b1;
		        end
		S_READY3:begin
		        enable = 1'b1;
	      		plot = 1'b1;
		        end
		S_READY4:begin
		        enable = 1'b1;
	      		plot = 1'b1;
		        end
	    endcase
	end
 
        reg [3:0] clock_counter;
        
		
	//slowdown clock to give enough time to draw before moving on	
	always@(posedge clock)
        begin: state_FFs
            if(!reset_n) begin
                current_state <= S_STARTING;
					 clock_counter<= 4'b1110;
					 end
            else if(clock_counter == 4'b0000) begin
                // change line counter so that eventually whole line is drawn
                if(current_state == S_READY0) 
                    line_counter = line_counter - 1'd1;
                //will only draw ground once so no need to reset line_counter
                current_state <= next_state;
                clock_counter <= 4'b1110;
                end
            else
                clock_counter <= clock_counter - 1'd1;
      end
 
endmodule

module datapath(clock, reset_n, jump_key,  enable, load_box1 , load_box2, load_box3,  load_person,  x, y, colour_out);
	input           	reset_n, clock, enable, load_box1, load_box2, load_box3, load_person;
	output reg	[7:0] 	x;
	output reg	[6:0] 	y;
	output reg 	[2:0]	colour_out;
    reg         [7:0]   regX;
	reg     	[6:0]   regY;
    reg         [2:0]   regC;
	
    wire       [1:0]    c1, c2;
	wire       [3:0]    c0;

    reg        [7:0]    box_1_x, box_2_x, box_3_x, person_x;
    reg        [6:0]    box_1_y, box_2_y, box_3_y, person_y; 
     
    localparam GROUND_TOP = 7'd100;
         

    counter cnt0(
     .clock(clock),
     .reset_n(reset_n),
     .enable(enable),
     .out(c0)
    );

    wire erase;
    wire game_over;

    datapath_move(clock, reset_n, jump_key, box_1_x, box_1_y,box_2_x,box_2_y,box_3_x,
                      box_3_y, person_x, person_y, erase, game_over);
        
		  
    assign c1 = c0[1:0];
	assign c2 = c0[3:2];

 
	
	always @ (posedge clock) begin
            if (!reset_n) begin
                regX <= 8'd0; 
                regY <= 7'd0;
		          regC <= 3'd0;
         
                
            end
            else begin
                if (load_box1) begin
                    regX <= box_1_x;
                    regY <= box_1_y;
                    //white colour box
		    regC <= 3'b111;
                end
                else if (load_box2) begin
                    regX <= box_2_x;
                    regY <= box_2_y;
                    //white colour box
		    regC <= 3'b111;
                end
                else if (load_box3) begin
                    regX <= box_3_x;
                    regY <= box_3_y;
                    //white colour box
		    regC <= 3'b111;
                end
                
                if (load_person) begin
                    regX <= person_x;
                    regY <= person_y;
                    //red colour person
		            regC <= 3'b100;
                end
                if (load_person) begin
                    regY <= GROUND_TOP;
                    //green colour ground
		            regC <= 3'b010;
                end
                //set everything to red to indicate game over
                if(game_over)
                    regC <= 3'b100;
            end
        end

     wire [7:0] ground_count;

     ground_counter gc(clock, reset_n, load_ground, ground_count);

     always @ (posedge clock) begin
          if (!reset_n) begin
              x <= 8'd0;
              y <= 7'd0;
              colour_out <= 3'd0;
          end
          else if (load_ground) begin
              x <= ground_count;
              y <= regY + c2;
              colour_out <= regC;
				  end
          else begin
              //counter draws a 4 x 4 square
              x <= regX + c1;
              y <= regY + c2;
              if(erase == 1'b1)
                  //erase by setting colour to black
                  colour_out <= 3'b000;
              else 
                  colour_out <= regC;
          end
     end

endmodule
	


module datapath_move(clock, reset_n, jump,  box_1_x, box_1_y,box_2_x,box_2_y,box_3_x,
                     box_3_y, person_x, person_y, erase, game_over);
        
        input clock, reset_n;
        input jump;
        
        output reg        [7:0]    box_1_x, box_2_x, box_3_x, person_x;
        output reg        [6:0]    box_1_y, box_2_y, box_3_y, person_y; 
        output erase;
        output reg game_over;
        
        wire enable_f, enable_x;
        wire [19:0] do;
        wire [3:0] fo;

        localparam GROUND_TOP = 7'd100;
        localparam BLOCK_WIDTH = 2'd2;
        localparam SCREEN_WIDTH = 8'd160;
        localparam JUMP_HEIGHT = 4'd20;

     

        always@(negedge reset_n) begin
                // start positions
                person_x <= 7'd10;
                person_y <= GROUND_TOP;

                box_1_x <= 7'd20;
                box_1_y <= GROUND_TOP;
       
                box_2_x <= 7'd60;
                box_2_y <= GROUND_TOP;
       
                box_3_x <= 7'd120;
                box_3_y <= GROUND_TOP;

                game_over <= 1'b0;
        end
       
        
        delay_counter dc(clock,reset_n, enable,do);

        frame_counter fc(clock,reset_n,enable_f,fo); 

        wire slowed_clock; 
        assign slowed_clock = (do == 20'b0) ? 1 : 0;

        wire collision;

        detectCollision d0(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);
        
        if(collision == 1’b0)
            detectCollision d1(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);

        if(collision == 1’b0)
            detectCollision d2(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);

        if(collision == 1’b0) begin
            moveBlock mb1(slowed_clock, box_1_x, box_1_y, GROUND_TOP, BLOCK_WIDTH, SCREEN_WIDTH);
            moveBlock mb2(slowed_clock, box_2_x, box_2_y, GROUND_TOP, BLOCK_WIDTH, SCREEN_WIDTH);
            moveBlock mb3(slowed_clock, box_3_x, box_3_y, GROUND_TOP, BLOCK_WIDTH, SCREEN_WIDTH);
            end
        else
            game_over = 1'b1;
        
        //move_player logic
        localparam REDUCE_HEIGHT = 2;

        always @(posedge slowed_clock) begin

           //if jump key is pressed, and player was on ground, then jump
           //TODO : Jump slowly
           if(jump && player_y <= ground_top + MAX_JUMP_HEIGHT)
                 player_y <= player_y + jump_height;

           //lower player slowly if player was in sky
           else if(player_y > ground_top) 
               player_y <= player_y - REDUCE_HEIGHT;

       end
       
       //keep on erasing after every 4 clock cycles
       assign erase = (fo == 4'b1111) ? 1'b1: 1'b0;
        
        
endmodule

module counter(clock, reset_n, enable, out);
	input 		clock, reset_n, enable;
	output reg [3:0] out;

	 
	
	always @(posedge clock) begin
		if(reset_n == 1'b0)
			out <= 4'd0;
		else if (enable == 1'b1)
		    begin
		    if (out == 4'b1111)
			    out <= 4'd0;
		    else
			    out <= out + 1'b1;
		end
   end
	

	
endmodule

module ground_counter(clock, reset_n, enable, out);
	input 		clock, reset_n, enable;
	output reg [7:0] out;

	 
	
	always @(posedge clock) begin
		if(reset_n == 1'b0)
			out <= 8'd160;
		else if (enable == 1'b1)
		    begin
		    if (out == 8'd160)
			    out <= 8'd0;
		    else
			    out <= out + 1'd1;
		end
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
                                q <= 20'hCEE61;
                        else if(enable ==1'b1)
                        begin
                           if ( q == 20'd0 )
                                        q <= 20'hCEE61;
                                else
                                        q <= q - 1'b1;
                        end
                end
 endmodule

