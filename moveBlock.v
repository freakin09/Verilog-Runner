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
                block_y <= block_y + y_change;
            //if block was above ground
            else
                block_y <= block_y - y_change;
        end
        else
            block_x <= block_x - 1;

    end   

endmodule

module randomPosition(clock, x_displacement, y_displacement);

    output reg [4:0] x_position, y_position;
    reg   above_ground;
    
    always @(posedge clock) begin
        x_postion  <= $urandom%20;
        
        above_ground <= $urandom%2;
    
        //if above_ground is even, then ground_height
        if(above_ground == 1'b0)
            y_displacement <= 5'b0;
        else
            y_displacement <= 5'd15;

endmodule
