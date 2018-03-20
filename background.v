// Part 2 skeleton

module background
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
    wire load_box1, load_box2, load_box3, load_person, enable;
    // Instansiate datapath
	// datapath d0(...);
    datapath d0(CLOCK_50,KEY[0], enable, load_box1, load_box2, load_box3, load_person, x, y, colour);
    // Instansiate FSM control
    // control c0(...);
    control c0(~KEY[3],KEY[0],CLOCK_50,enable,load_box1, load_box2, load_box3, load_person,writeEn); 
endmodule

module control(go,reset_n, clock, enable, load_box1, load_box2, load_box3, load_person, plot);
	
      input go,reset_n,clock;
		
		output reg enable,load_box1,load_box2,load_box3, load_person,plot;
		
		reg [3:0] current_state, next_state;

		
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
						  
						  S_STARTING           = 4'd12;
		
		
		always@(*)
        begin: state_table 
            case (current_state)
                
                S_STARTING : next_state = go ? S_LOAD_BOX1 : S_STARTING; 
                //DRAW box1
                S_LOAD_BOX1: next_state = go ? S_LOAD_BOX1_WAIT : S_LOAD_BOX1; 
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
            load_box1 = 1'b0;
            load_box2 = 1'b0;
            load_box3 = 1'b0;
            load_person = 1'b0;
	    enable = 1'b0;
            plot = 1'b0;
		    
	    case(current_state)
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
                current_state <= next_state;
                clock_counter <= 4'b1110;
                end
            else
                clock_counter <= clock_counter - 1'd1;
      end
 
endmodule

module datapath(clock, reset_n, enable, load_box1 , load_box2, load_box3,  load_person,  x, y, colour_out);
	input           	reset_n, clock, enable, load_box1, load_box2, load_box3, load_person;
	output reg	[7:0] 	x;
	output reg	[6:0] 	y;
	output reg 	[2:0]	colour_out;
        reg             [7:0]   regX;
	reg     	[6:0]   regY;
        reg             [2:0]   regC;
	
        wire           [1:0] c1, c2;
	wire           [3:0] c0;

        reg            [6:0] box_1_x,box_1_y,box_2_x,box_2_y,box_3_x,box_3_y, person_x, person_y; 
     
        localparam GROUND_TOP = 7'd30;
         

        counter cnt0(
          .clock(clock),
          .reset_n(reset_n),
          .enable(enable),
          .out(c0)
          );
		  
        assign c1 = c0[1:0];
	assign c2 = c0[3:2];

 
	
	always @ (posedge clock) begin
            if (!reset_n) begin
                regX <= 8'd0; 
                regY <= 7'd0;
		          regC <= 3'd0;
					 
					 //hard_code for test purposes

                person_x = 7'd10;
                person_y = GROUND_TOP;
         
                box_1_x = 7'd20;
                box_1_y = GROUND_TOP;
       
                box_2_x = 7'd60;
                box_2_y = GROUND_TOP;
       
                box_3_x = 7'd120;
                box_3_y = GROUND_TOP;
            end
            else begin
                if (load_box1) begin
                    regX <= {1'b0, box_1_x};
                    regY <= box_1_y;
                    //white colour box
		    regC <= 3'b111;
                end
                else if (load_box2) begin
                    regX <= {1'b0, box_2_x};
                    regY <= box_2_y;
                    //white colour box
		    regC <= 3'b111;
                end
                else if (load_box3) begin
                    regX <= {1'b0, box_3_x};
                    regY <= box_3_y;
                    //white colour box
		    regC <= 3'b111;
                end
                
                if (load_person) begin
                    regX <= {1'b0, person_x};
                    regY <= person_y;
                    //red colour person
		    regC <= 3'b100;
                end
            end
        end

     always @ (posedge clock) begin
          if (!reset_n) begin
              x <= 8'd0;
              y <= 7'd0;
              colour_out <= 3'd0;
          end
          else begin
              //counter draws a 4 x 4 square
              x <= regX + c1;
              y <= regY + c2;
              colour_out <= regC;
          end
     end

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

