`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/13 00:17:44
// Design Name: 
// Module Name: record_light
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


module record_light( input clk,
                     input rst,
                     input power_now,
                     input [23:0]record,
                     output reg [7:0] seg_enable,//八个信号的使能
                     output [7:0] seg_left,//左边四个灯
                     output [7:0] seg_right//右边四个灯

    );
endmodule
