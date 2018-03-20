module detectCollision(runner_x, runner_y,runner_width, runner_height,
                       block_x, block_y, block_width, block_height,
                       collision);
    
    input runner_x, runner_y, block_x, block_y;
    output collision;

    always @(*) begin
        // if runner is in touch with block, set collision to high
        if(runner_x >= block_x && 
           runner_x + runner_width <= block_x + block_with &&
           runner_y >= block_y && 
           runner_y + runner_height <= block_y + block_height)
           
           collision = 1;

        else
            collision = 0;

    end


end module;
