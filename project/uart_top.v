`timescale 1ns / 1ps

/*
数据输入输出规则：

EGO1发送给软件的8bit数据，前4bit一次对应四种操作：前进、后退、左转、右转。最高bit为验证位，必须保持1，否则软件会主动断连。

EGO1接收到的8bit数据，前4bit对应前左右后四个传感器的信号，实时更新，后4bit暂时没用。（其中后方信号因为没啥用，所以暂时没开）

*/
module uart_top(
    input clk,//时钟输入
    input rst,
    input[7:0] data_in, //数据输入
    output[7:0] data_rec,//段码
    input rxd,  //数据接收 
    output txd //数据发送
); 

wire clk_ms,clk_20ms,clk_16x,clk_x;
wire data_ready;//数据是否准备好
wire data_error;
wire send_ready;

reg send = 0;
always @(posedge clk_ms) 
    send = ~send;
    
//调用分频模块
//clk 输入时钟50Mhz
//clk_ms 输出时钟1Khz
//clk_20ms 输出时钟50Hz
//clk_x 输出时钟9600Hz
//clk_16x 输出时钟9600hz*16
divclk my_divclk(
    .clk(clk),
    .clk_ms(clk_ms),
    .btnclk(clk_20ms),
    .clk_16x(clk_16x),
    .clk_x(clk_x)
);

uart_tx tx(//调用串口发送模块
    .clk_x(clk_x),
    .rst(rst),
    .data_in({1'b1,data_in[6:0]}),
    .send(send),
    .trans_done(send_ready),
    .txd(txd)
    );
uart_rx rx(
    .clk_16x(clk_16x),
    .rst(rst),
    .rxd(rxd),
    .data_rec(data_rec),
    .data_ready(data_ready),
    .data_error(data_error)
);
endmodule

//
//分频模块
/*
clk:输入时钟100MHZ
clk_ms:输出时钟 1KHz
clk_20ms:输出时钟50HZ
clk_x 输出时钟9600HZ
clk_16x 输出时钟9600hz*16
*/

module divclk(clk,clk_ms,btnclk,clk_16x,clk_x);
input clk;
output clk_ms,btnclk,clk_16x,clk_x;
reg[31:0] cnt1=0;
reg[31:0] cnt2=0;
reg[31:0] cnt3=0;
reg[31:0] cntclk_cnt=0;
reg clk_ms=0;
reg btnclk=0;
reg clk_16x=0;
reg clk_x=0;
always@(posedge clk)//系统时钟分频 100M/1000 = 100000   1000HZ
begin
    if(cnt1==26'd50000)
    begin
        clk_ms=~clk_ms;
        cnt1=0;
    end
    else
        cnt1=cnt1+1'b1;
end
always@(posedge clk)//20MS: 100M/50 = 2000 000   50HZ
begin
    if(cntclk_cnt==500000)
    begin
        btnclk=~btnclk;
        cntclk_cnt=0;
    end
    else
        cntclk_cnt=cntclk_cnt+1'b1;
end
always@(posedge clk)//100M/153600 = 651       9.6K*16=153.6k
begin
    if(cnt2=='d326)
    begin
        clk_16x<=~clk_16x;
        cnt2<='d0;
    end
    else
        cnt2=cnt2+1'b1;
end
always@(posedge clk)//100M/9600 = 10416.67       9600HZ
begin
    if(cnt3=='d5208)
    begin
        clk_x<=~clk_x;
        cnt3<= 0;
    end
    else
        cnt3=cnt3+1'b1;
end
endmodule

