module moveBlock(slowed_clock, block_x, block_y, ground_top, block_width, screen_width);

    input slowed_clock;
    input block_width;
    input screen_width;
    input ground_top;
    inout reg block_x, block_y;

    reg x_change, y_change;

    randomPosition rp0(slowed_clock, x_change, y_change);

    always @(posedge slowed_clock) begin

        
        // move_block to the end at some random position 
        if(block_x + block_width <= 0) begin
            
            block_x <= screen_width + x_change;
            
            //if block was on ground
            if(block_y <= ground_top)
                block_y <= block_y - y_change;   // - => above ground
            //if block was above ground
            else
                block_y <= block_y + y_change;
        end
        else
            block_x <= block_x - 1;

    end   

endmodule

module randomPosition(clock, x_displacement, y_displacement);
     
	 input clock; 

    output reg [4:0] x_displacement, y_displacement;
    reg   above_ground;
    
    always @(posedge clock) begin
        x_displacement  <= $urandom%20;
        
        above_ground <= $urandom%2;
    
        //if above_ground is even, then ground_height
        if(above_ground == 1'b0)
            y_displacement <= 5'b0;
        else
            y_displacement <= 5'd15;
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
