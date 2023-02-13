module turn_led_top_sim();
       reg clk=0;
       reg clk_bps=0;
       reg rst=0;
       reg power=0;             
       reg [3:0] state=4'b0100;
      reg[26:0] record=0;
      wire[7:0] led;
       wire [7:0] seg_led1;
    wire [7:0] seg_led2;
  flash_led_ctrl xixi(
    .clk(clk),
    .rst_n(rst),
    .power_now(power),
    .clk_bps(clk_bps),
    .state1(state),
    .record(record),
    .led(led),
    .seg_led1(seg_led1),
    .seg_led2(seg_led2)
    );

initial begin
    forever begin
        #1begin clk=~clk;
               clk_bps=~clk_bps;
        end
    end
end
initial begin
        repeat(100) begin
           #1  {record}={record}+1;
        end
         #1 state=4'b1000;
        repeat(100) begin
           #1  {record}={record}+1;
        end
        #1state=4'b0010;
             repeat(100) begin
           #1  {record}={record}+1;
        end
        #1state=4'b0001;
         repeat(100) begin
           #1  {record}={record}+1;
        end
        #1state=4'b1000;
         repeat(100) begin
           #1  {record}={record}+1;
        end
        #10 rst=1;
        #10 rst=0;
        #10 power=1;
       repeat(100) begin
           #1  {record}={record}+1;
        end
    $finish();
end
endmodule