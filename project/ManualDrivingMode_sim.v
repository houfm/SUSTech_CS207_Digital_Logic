`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/24 10:00:16
// Design Name: 
// Module Name: ManualDrivingMode_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ManualDrivingMode_sim();
                            reg clk =0;
                            reg rst = 0;
                            reg power_input=0;
                            reg throttle=0;
                            reg clutch =0;
                            reg brake =0;
                            reg reverse=0;
                            reg turn_left_signal=0;
                            reg turn_right_signal=0;
                            wire [3:0] answer;
                            wire [3:0] state;
                            wire power_now ;

                     ManualDrivingMode manual_top(
    .clk(clk),
    .rst(rst),
    .power_input(power_input),
    .throttle(throttle),
    .clutch(clutch),
    .brake(brake),
    .reverse(reverse),
    .turn_left_signal(turn_left_signal),
    .turn_right_signal(turn_right_signal),
    .answer(answer),
    .state(state),
    .power_now(power_now)
    );
    initial begin
    forever begin
        #1 clk=~clk;
    end
end
    initial begin//unstarting
       repeat(15) begin #10 {clutch,throttle,brake,power_input}={clutch,throttle,power_input}+1;
       end
     //  starting
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b0010;

                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b0100;

                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b0110;

                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b1000;

                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b1010;

                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b1100;

                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{clutch,throttle,brake,power_input}=4'b1110;

//moving            
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10 {clutch,brake,reverse,power_input}=4'b0010;

                     #10 rst=1;
                    #10 rst=0;
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{clutch,brake,reverse,power_input}=4'b0100;

                     #10 rst=1;
                    #10 rst=0;
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{clutch,brake,reverse,power_input}=4'b0110;

                     #10 rst=1;
                    #10 rst=0;
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{clutch,brake,reverse,power_input}=4'b1000;

                     #10 rst=1;
                    #10 rst=0;
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{clutch,brake,reverse,power_input}=4'b1010;

                     #10 rst=1;
                    #10 rst=0;
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{clutch,brake,reverse,power_input}=4'b1100;

                    #10 rst=1;
                    #10 rst=0;
                    #10{clutch,throttle,brake,power_input}=4'b1100;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{clutch,brake,reverse,power_input}=4'b1110;


//power off
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                     #10 {clutch,throttle,brake,power_input}=4'b1100;

                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10 {clutch,throttle,brake,power_input}=4'b1100;
                     #10 {clutch,throttle,brake,power_input}=4'b0100;

                    #10 rst=1;
                    #10{clutch,throttle,brake,reverse,power_input}=5'b11000;
                    #10 rst=0;
                      #10{clutch,throttle,brake,reverse,power_input}=5'b11000;
                      #10{clutch,throttle,brake,reverse,power_input}=5'b00010;
                      #10{clutch,throttle,brake,reverse,power_input}=5'b01010;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b000;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b001;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b010;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b011;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b100;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b101;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b110;
                      #10{turn_right_signal,turn_left_signal,reverse}=3'b111;

                   
                     #10{clutch,throttle,brake,reverse,power_input}=5'b11000;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b000;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b001;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b010;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b011;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b100;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b101;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b110;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b111;
                     
                     #10{clutch,throttle,brake,reverse,power_input}=5'b11000;
                    #10{clutch,throttle,brake,power_input}=4'b0000;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b000;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b001;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b010;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b011;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b100;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b101;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b110;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b111;

                     #10{clutch,throttle,brake,reverse,power_input}=5'b11000;
                    #10{clutch,throttle,brake,power_input}=4'b0100;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b000;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b001;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b010;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b011;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b100;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b101;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b110;
                    #10{turn_right_signal,turn_left_signal,reverse}=3'b111;

                      $finish();
       
    
    end

    
    
endmodule
