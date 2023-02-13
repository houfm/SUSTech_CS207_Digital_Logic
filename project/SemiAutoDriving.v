`timescale 1ns / 1ps


module SemiAutoDriving(
input clk,
input semi_auto_mode_on,
input reset,
input front_detector,
input back_detector,
input left_detector,
input right_detector,

input turn_left_command,
input turn_right_command,
input go_straight_command,
input turn_back_command,

output reg move_forward,
output reg turn_left,
output reg turn_right,
output reg move_backward
);

reg [2:0] state;
//000 Wait-for-command,001 Turn-Right,010 Turn-Left,011 Go-Straight,100 Go-Back
reg wall;

reg [31:0] counter;
wire clk_100hz;
clk_div_100HZ cl(.clk(clk),.clk_100HZ(clk_100hz));

wire [3:0] detectors;
assign detectors={back_detector,front_detector,left_detector,right_detector};


always @(posedge clk_100hz) begin
    if (reset) begin
        state<=3'b000;
        wall<=0;
        counter<=8'b00000000;
        {move_backward,move_forward,turn_left,turn_right}<=4'b0000;
    end
    else if(semi_auto_mode_on==1'b1)begin
        counter<=counter+1'b1;
        case(state)
            3'b000:begin
                if (go_straight_command) begin
                    state <= 3'b011;
                    counter<=8'b00000000;
                wall<=0;
                end
                else if (turn_right_command) begin
                    state <= 3'b001;
                    counter<=8'b00000000;
                wall<=0;
                end
                else if (turn_left_command) begin
                    state <= 3'b010;
                    counter<=8'b00000000;
                wall<=0;
                end
                else if(turn_back_command) begin
                    state<=3'b100;
                    counter<=8'b00000000;
                wall<=0;
                end
            end
            3'b001:begin
                if (counter>=8'd90) begin
                    // if (front_detector==0) begin
                        state <= 3'b011;
                        counter<=8'b00000000;
                wall<=0;
                    // end
                end
            end
            3'b010:begin
                if (counter>=8'd90) begin
                    // if (front_detector==0) begin
                        state <= 3'b011;
                        counter<=8'b00000000;
                wall<=0;
                    // end
                end
            end
            3'b011:begin
                if (!wall) begin
                        if(counter>=8'd45) begin
                            if (detectors==4'b0100||detectors==4'b0010||detectors==4'b0001||detectors==4'b0000) begin
                                state<=3'b000;
                                counter<=8'b00000000;
                            end 
                        end
                        if (detectors==4'b0110) begin
                            counter<=0;
                            wall<=1;
                        end 
                        else if (detectors==4'b0101) begin
                            counter<=0;
                            wall<=1;
                        end
                        else if (detectors==4'b0111) begin
                            counter<=0;
                            wall<=1;
                        end
                        else if(detectors==4'b0100) begin
                            counter<=0;
                            wall<=1;
                        end
                end
                else if(wall) begin
                    if(counter>=8'd00_000_006) begin
                        if (detectors==4'b0110) begin                      
                            state <= 3'b001;
                            counter<=8'b00000000;
                        end 
                        else if (detectors==4'b0101) begin
                            state <= 3'b010;
                            counter<=8'b00000000;
                        end
                        else if (detectors==4'b0111) begin
                            state<=3'b100;
                            counter<=8'b00000000;
                        end
                        else if(detectors==4'b0100) begin
                            state<=3'b000;
                            counter<=8'b00000000;
                        end
                        // wall<=0;
                    end
                end
            end
            3'b100:begin
                if (counter>=8'd180) begin
                    state <= 3'b011;
                    counter<=8'b00000000;
                    wall<=0;
                end               
            end
            endcase

            case (state)
                3'b000:  {move_backward,move_forward,turn_left,turn_right}<=4'b0000;
                3'b001:  {move_backward,move_forward,turn_left,turn_right}<=4'b0001;
                3'b010:  {move_backward,move_forward,turn_left,turn_right}<=4'b0010;
                3'b011:  {move_backward,move_forward,turn_left,turn_right}<=4'b0100;
                3'b100:  {move_backward,move_forward,turn_left,turn_right}<=4'b0001;
                default: {move_backward,move_forward,turn_left,turn_right}<={move_backward,move_forward,turn_left,turn_right};
            endcase
        end 
        else begin
            {move_backward,move_forward,turn_left,turn_right}<=4'b0000;
        end
    end
endmodule
