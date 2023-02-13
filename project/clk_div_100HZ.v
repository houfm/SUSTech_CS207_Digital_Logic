`timescale 1ns / 1ps


module clk_div_100HZ(input clk,output reg clk_100HZ);
    parameter period = 1_000_000;
    reg [31:0] cnt;
    always@(posedge clk)
    begin
        // if (reset)begin
        //     cnt     <= 0;
        //     clk_out <= 0;
        // end
        // else
            if (cnt == ((period>>1)-1))begin
                clk_100HZ <= ~clk_100HZ;
                cnt     <= 0;
            end
            else begin
                cnt <= cnt+1;
            end
    end
endmodule