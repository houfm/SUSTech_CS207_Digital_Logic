`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/13 14:36:37
// Design Name: 
// Module Name: turn_left_right_light
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


module turn_left_right_light(
                             input rst,
                             input clk,
                             input power_now,//小车现在是通电还是断电状态
                             input [3:0] state,//4'b0001为unstarting状态，4'b0010为starting状态，4'b0100为moving状态，4'b1000为power_off状态
                             input [3:0]answer,//左转，右转，后退，前进信号
                             output reg left_led,
                             output reg right_led
                            
                                );
  wire clk_2hz;
  reg cur=0;
  reg cur1=0;
  reg[2:0] count;
  reg[2:0] count1;
  reg [1:0] temp;
          cik_div_2HZ manual_record(//和里程记录使用的分频器一样
                                    .clk(clk),
                                    .clk_2HZ(clk_2hz)
        );

//调整闪烁频率
       always @(posedge clk_2hz or negedge rst) begin
              if(rst)begin
		count=3'd00;
		end
	else if( count==2)
	begin
		cur=~cur;
              count=0;
	end
	else
		count=count+1'b1;

       end
       always @(posedge clk_2hz or negedge rst) begin
              if(rst)begin
		count1=3'd00;
		end
	else if( count1==2)
	begin
		cur1=~cur1;
              count1=0;
	end
	else
		count1=count1+1'b1;
       end
//使用状态机划分状态
             always @(posedge clk or negedge rst) begin
                      if(rst||power_now) begin
                            temp<=2'b00;
                      end
                     else begin
                     case (temp)
                     2'b00:begin
                            if(state==4'b0100||state==4'b0010)begin
                                  temp<=2'b01;
                            end
                     
                            end
                     2'b01:begin
                            if(state!=4'b0100&&state!=4'b0010)begin
                                  temp<=2'b00;
                            end
                             else if(answer[3]==1)begin
                                   temp<=2'b10;
                            end
                             else if(answer[2]==1)begin
                                   temp<=2'b11;
                            end
                     end
                      2'b10:begin
                            if(answer[3]!=1)begin
                                  temp<=2'b00;
                            end
                     end
                     2'b11:begin
                            if(answer[2]!=1)begin
                                  temp<=2'b00;
                            end
                     end
                     endcase
             end
             end
             //对不同状态进行赋值
           always @(posedge clk) begin
              case(temp) 
                     2'b00:begin
                            left_led<=0;
                            right_led<=0;
                     end
                     2'b01:begin
                            left_led<=0;
                            right_led<=0;
                     end
                     2'b10:begin
                            left_led<=cur;
                            right_led<=0;
                     end
                     2'b11:begin
                            left_led<=0;
                            right_led<=cur1;
                     end
              endcase
           end

endmodule