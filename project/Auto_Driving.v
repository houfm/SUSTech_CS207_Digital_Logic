`timescale 1ns / 1ps


module Auto_Driving(
input clk,
input auto_mode_on,
input reset,
input front_detector,
input back_detector,
input left_detector,
input right_detector,


// input place_beacon,
// input destroy_beacon,

output reg  move_forward,
output reg turn_left,
output reg turn_right,
output reg move_backward,

output reg place_barrier_signal,
output reg destroy_barrier_signal


);

reg [2:0] state;
//000 Origin,001 Turn-Right,010 Turn-Left,011 Go-Straight,100 Go-Back,111 Special-GoBack(起点时只有后方有路),110(销毁障碍)
reg wall;

reg [7:0] counter;
reg [7:0] another_cnt;
reg turned_right,turned_back;
reg tmp;

wire clk_100hz;
clk_div_100HZ cl(.clk(clk),.clk_100HZ(clk_100hz));
wire [3:0] detectors;
assign detectors={back_detector,front_detector,left_detector,right_detector};


always @(posedge clk_100hz) begin
    if (reset) begin
        state<=3'b000;
        wall<=0;
        counter<=8'd50;
        another_cnt<=0;
        turned_right<=0;
        turned_back<=0;
        {move_backward, move_forward,turn_left,turn_right}<=4'b0000;
        tmp<=0;
    end
    else if(auto_mode_on==1'b1)begin
        counter<=counter+1'b1;
        another_cnt<=another_cnt+1'b1;
        case(state)
            3'b110: begin
                if(another_cnt==8'd5)begin
                    destroy_barrier_signal<=1;
                end
                if(another_cnt==8'd10) begin
                    destroy_barrier_signal<=0;
                end
                if(another_cnt>=8'd50) begin
                    // destroy_barrier_signal<=0;
                    wall<=0;
                    counter<=8'd50;
                    state<=3'b011;
                    another_cnt<=8'b0;
                    // turned_back<=0;
                    // turned_right<=0;
                end
            end
            3'b000:begin
                if(detectors==4'b0111) begin
                    state<=3'b111;
                    counter<=8'b00000000;
                end
                else begin
                    state=3'b011;
                    counter<=8'd50;
                end
            end
            3'b001:begin
                if (counter>=8'd90) begin
                    // if (front_detector==0) begin
                        state <= 3'b011;
                        counter<=8'b00000000;
                        wall<=0;
                        turned_right<=1;
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
                if(turned_right) begin
                    // another_cnt<=another_cnt+1;
                    if(counter==8'd75) begin
                        place_barrier_signal<=1;
                    end
                    else if(counter==8'd80) begin
                        place_barrier_signal<=0;
                        turned_right<=0;
                    end
                end

                if (!wall) begin
                        if(counter>=8'd40) begin
                            if (detectors==4'b0100||detectors==4'b0010||detectors==4'b0000||
                                detectors==4'b1100||detectors==4'b1010||detectors==4'b1000) begin
                                state<=3'b001;
                                counter<=8'b00000000;
                                if(turned_back) begin
                                    turned_back<=0;
                                end
                            end 
                            else if(detectors==4'b0001||detectors==4'b1001) begin
                                state<=3'b011;
                                counter<=8'b00000000;
                                if(turned_back) begin
                                    turned_back<=0;
                                end
                            end
                        end
                        if (detectors==4'b0110||detectors==4'b1110) begin
                            counter<=0;
                            wall<=1;
                        end 
                        else if (detectors==4'b0101||detectors==4'b1101) begin
                            counter<=0;
                            wall<=1;
                        end
                        else if (detectors==4'b0111||detectors==4'b1111) begin
                            counter<=0;
                            wall<=1;
                        end
                        else if(detectors==4'b0100||detectors==4'b1100) begin
                            counter<=0;
                            wall<=1;
                            if(turned_back) begin
                                turned_back<=0;
                            end
                        end
                end
                else if(wall) begin
                    if(counter>=8'd8) begin
                        if (detectors==4'b0110||detectors==4'b1110) begin                      
                            state <= 3'b001;
                            counter<=8'b00000000;
                        end 
                        else if (detectors==4'b0101||detectors==4'b1101) begin
                            state <= 3'b010;
                            counter<=8'b00000000;
                        end
                        else if(detectors==4'b0100||detectors==4'b1100) begin
                            state<=3'b001;
                            counter<=8'b00000000;
                            if(turned_back) begin
                                turned_back<=0;
                            end
                        end
                        else if (detectors==4'b0111||detectors==4'b1111) begin
                            if(turned_back && tmp==0) begin
                                state<=3'b110;
                                counter<=8'b00000000;
                                another_cnt<=8'b0;
                                wall<=0;
                                tmp<=1;
                            end
                            else begin
                                state<=3'b100;
                                counter<=8'b00000000;
                            end
                        end
                        else begin
                            wall<=0;
                        end
                    end
                end
            end
            3'b100:begin
                if (counter>=8'd180) begin
                    state <= 3'b011;
                    counter<=8'b00000000;
                    turned_back<=1;
                    wall<=0;
                end               
            end
            3'b111:begin
                if (counter>=8'd180) begin
                    state <= 3'b011;
                    counter<=8'b00000000;
                    wall<=0;
                end             
            end
        endcase

        case (state)
            3'b000:  {move_backward, move_forward,turn_left,turn_right}<=4'b0000;
            3'b001:  {move_backward, move_forward,turn_left,turn_right}<=4'b0001;
            3'b010:  {move_backward, move_forward,turn_left,turn_right}<=4'b0010;
            3'b011:  {move_backward, move_forward,turn_left,turn_right}<=4'b0100;
            3'b100:  {move_backward, move_forward,turn_left,turn_right}<=4'b0001;
            3'b111:  {move_backward, move_forward,turn_left,turn_right}<=4'b0001;
            // default: {move_backward, move_forward,turn_left,turn_right}<={move_backward, move_forward,turn_left,turn_right};
            default:  {move_backward, move_forward,turn_left,turn_right}<=4'b000;
        endcase
    end 
    else begin
        {move_backward, move_forward,turn_left,turn_right}<=4'b0000;
    end
end

endmodule
