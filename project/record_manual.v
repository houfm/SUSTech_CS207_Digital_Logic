`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/12 23:33:20
// Design Name: 
// Module Name: record_manual
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


module record_manual(//我设计的是每0.5s里程加一
        
                         input clk,
                         input rst,
                         input power_now,//必须是通电状态才有效
                        
                         input [3:0] state,//输入手动挡的状态
                         output reg[26:0] record   );
        wire clk_2hz;
        cik_div_2HZ manual_record(
                                    .clk(clk),
                                    .clk_2HZ(clk_2hz)
        );

     always@(negedge clk_2hz )begin
           if(power_now||rst||record==27'd999_9999)begin
                record<=0;
            end
            else if(state==4'b0100) begin
                record<=record+1;
            end
        end


endmodule
