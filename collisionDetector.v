module detectCollision(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);
    
    input [7:0] runner_x, block_x;
    input [6:0] runner_y, block_y;
	 input [1:0] block_width,block_height, runner_width, runner_height;
    output reg collision;

    always @(*) begin
        // if runner is in touch with block, set collision to high
        if(runner_x >= block_x && 
           runner_x + runner_width <= block_x + block_width &&
           runner_y >= block_y && 
           runner_y + runner_height <= block_y + block_height)
           
            collision <= 1'b1;

        else
            collision <= 1'b0;

    end


endmodule
