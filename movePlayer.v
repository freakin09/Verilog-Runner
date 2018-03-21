module movePlayer(clock, player_y, ground_top,jump_height, jump);
     
     input     clock;
     input     jump;
     input     jump_height;
     input     ground_y;
     inout reg player_y;

     reg [25:0] rate_dividor
     
     localparam REDUCE_HEIGHT = 5;

     //if jump key is pressed, and player was on ground, then jump
     always @(posedge jump) begin
        
         if(player_y <= ground_top)
             player_y <= player_y + jump_height;
     end


    //lower player slowly if player was in sky
    always @(posedge clock) begin
        
        rate_dividor = rate_dividor + 1;
        
        if(rate_dividor == 26'h7A120) begin
            rate_divor <= 0;
            if(player_y > ground_top) 
                player_y <= player_y - REDUCE_HEIGHT;

        end
    end
            

       /* Logic to roll over
       
	always @(posedge roll_over) begin
	    //start timer
	    if(current_height == normal_height && timer != 0)
		current_height <= current_height - REDUCE_HEIGHT;
	    else if(timer == 0)
		current_height <= normal_height;
	end

       */

endmodule      
