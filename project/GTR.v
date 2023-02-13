// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 2022/12/07 22:54:41
// // Design Name: 
// // Module Name: GTR
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////



module GTR (input sys_clk,
                     input rst_n,
                     input throttle,              //油门
                     input clutch,                //离合
                     input brake,
                     input reverse,               //倒车
                     input rx,
                     output tx,
                     input turn_left_signal,
                     input turn_right_signal,
                     input move_forward_signal,
                     input move_backward_signal,

                     output reg power_on_led = 0,
                     output reg [2:0] mode_led,
                     output left_led,
                     output right_led,
                     input power_on,
                     input power_off,
                     input [2:0] mode_signal,

//                     output  power_now,
//                     output  change,
                     output [7:0] seg_enable,
                     output[7:0] seg_led1,
                     output [7:0] seg_led2,
                     output back_detector,
                     output left_detector,
                     output front_detector,
                     output right_detector,
                     output [3:0] red,
                    output [3:0] green,
                    output [3:0] blue, 
                     output hsync,
                     output vsync
                     );
    wire debounced_power_on; // when you instaintiate a submodlue, the register type can NOT be used and the wire type should be used.
    wire [3:0] answer; //手动挡依次输出左转，右转，后�?，前进信�?
    wire [3:0] answer1;//半自动挡依次输出左转，右转，后�??，前进信�?
    wire [3:0] answer2;//手动挡依次输出左转，右转，后�?，前进信�?
    wire [3:0] state;
    wire [26:0] record;
     wire change;
     wire power_now;
    reg manul_mode_on     ;
    reg semi_auto_mode_on = 0;
    reg auto_mode_on      = 0;
    wire place_barrier_signal;
    wire destroy_barrier_signal;
    debouncer d0(power_now,power_on,power_off,sys_clk,change,debounced_power_on);
    ManualDrivingMode manual_top(
    .clk(sys_clk),
    .rst(rst_n),
    .power_input(~manul_mode_on),
    .throttle(throttle),
    .clutch(clutch),
    .brake(brake),
    .reverse(reverse),
    .turn_left_signal(~turn_left_signal),
    .turn_right_signal(~turn_right_signal),
    .answer(answer),
    .state(state),
    .power_now(power_now),
    .change(change)
    );
    SemiAutoDriving sem_auto_driving(
    .clk(sys_clk),
    .reset(rst_n),
    .semi_auto_mode_on(semi_auto_mode_on),
    .front_detector(front_detector),
    .back_detector(back_detector),
    .left_detector(left_detector),
    .right_detector(right_detector),
    .turn_left_command(turn_left_signal),
    .turn_right_command(turn_right_signal),
    .go_straight_command(move_forward_signal),
    .turn_back_command(move_backward_signal),
    .turn_left(answer1[3]),
    .turn_right(answer1[2]),
    .move_backward(answer1[1]),
    .move_forward(answer1[0])
    );
    Auto_Driving auto_driving(
    .clk(sys_clk),
    .reset(rst_n),
    .auto_mode_on(auto_mode_on),
    .front_detector(front_detector),
    .back_detector(back_detector),
    .left_detector(left_detector),
    .right_detector(right_detector),
    .place_barrier_signal(place_barrier_signal),
    .destroy_barrier_signal(destroy_barrier_signal),
    .turn_left(answer2[3]),
    .turn_right(answer2[2]),
    .move_backward(answer2[1]),
    .move_forward(answer2[0])
    );
    record_manual record0(
    .clk(sys_clk),
    .rst(rst_n),
    .power_now(power_now),
    .state(state),
    .record(record)
    );
    flash_led_top flahs0(
    .clk(sys_clk),
    .rst_n(rst_n),
    .power_now(power_now),
    .state1(state),
    .record(record),
    .led(seg_enable),
    .seg_led1(seg_led1),
    .seg_led2(seg_led2)
    );
    turn_left_right_light turn_light0(
    .clk(sys_clk),
    .rst(rst_n),
    .power_now(power_now),
    .state(state),
    .answer(answer),
    .left_led(left_led),
    .right_led(right_led)
    );
    SimulatedDevice sim(
    sys_clk,
    rx,
    tx,
    ((answer[3]&manul_mode_on)||(answer1[3]&semi_auto_mode_on)||(answer2[3]&auto_mode_on)),
     ((answer[2]&manul_mode_on)||(answer1[2]&semi_auto_mode_on)||(answer2[2]&auto_mode_on)),
     
       ((answer[0]&manul_mode_on)||(answer1[0]&semi_auto_mode_on)||(answer2[0]&auto_mode_on)),
        ((answer[1]&manul_mode_on)||(answer1[1]&semi_auto_mode_on)||(answer2[1]&auto_mode_on)),
    place_barrier_signal,destroy_barrier_signal,
    front_detector,back_detector,left_detector,right_detector);   // NOT revised the bug in simulation.
    vga_top vga(
    sys_clk,
    debounced_power_on,
    manul_mode_on,
    semi_auto_mode_on,
    auto_mode_on,
    record,
    power_now,
    rst_n,
    hsync,
    vsync,
    red,
    green,
    blue
    );
    always @(*) begin
            

        case ({debounced_power_on})
            1'b1:
            begin
                power_on_led = 1'b1;
                // should be one
                case (mode_signal)
                    3'b001:
                    // the manual mode is on.
                    begin
                        mode_led       = 3'b001;
                        manul_mode_on     = 1'b1;
                        semi_auto_mode_on = 0;
                        auto_mode_on      = 0;
                        
                    end
                    3'b010:
                    begin
                       mode_led       = 3'b010;
                        manul_mode_on     = 0;
                        semi_auto_mode_on = 1'b1;
                        auto_mode_on      = 0;
                    end
                    3'b100:
                    begin
                      mode_led       = 3'b100;
                        manul_mode_on     = 0;
                        semi_auto_mode_on = 0;
                        auto_mode_on      = 1'b1;
                    end
                    default:
                    begin
                        mode_led       = 3'b000;
                        manul_mode_on     = 0;
                        semi_auto_mode_on = 0;
                        auto_mode_on      = 0;
                    end
                endcase
            end
            // 10 is the state when power on.
            1'b0:
            begin
                power_on_led      = 0;
                mode_led       = 3'b000;
                manul_mode_on     = 0;
                semi_auto_mode_on = 0;
                auto_mode_on      = 0;
               
            end
        endcase
    end


endmodule
    
    // Implementation of press and hold on power on button for at least 1 seconds,
    // the car will enable its engine.
    // 1/100 s
    module debouncer (
        input power_now,
        input power_on,
        input power_off,
        input sys_clk,
        input change,
        output reg debounced_power_on);
        // get the 100Hz clock first.
        wire debouncer_divclk;
        debouncer_clk_div div(sys_clk,debouncer_divclk);
        // get delay signals.
        reg[9:0] cnt = 0;
 
        always @(posedge debouncer_divclk) begin       
            casex ({power_on,power_off,change})
                3'b00X:
                // press the power_on button
                begin
                    case (cnt)
                        10'd1000: debounced_power_on <= 1'b1;
                        default:
                        begin
                            cnt                <= cnt+1'b1;
                            debounced_power_on <= 1'b0;
                        end
                    endcase
                end
                3'b11X:
                // press the power_off button
                begin
                    cnt <= 0;
                    debounced_power_on <= 1'b0;
                end
                default:
                if(change==1)begin
                     cnt <= 0;
                    debounced_power_on <= 1'b0;
                end
                // none of the button is pressed or both of the button is pressed.
                // At this circumstance, we can NOT  declear whether it is power on or off.
                else 
                 cnt <= 0;
                // press 2 button at the same time
            endcase
            //   if(power_now==1'b1)begin
            //         debounced_power_on=1'b0;
            //       end
           
        end
    endmodule
        module debouncer_clk_div (
            input sys_clk,
            output reg debouncer_divclk
            );
            reg[31:0] cnt = 0;
            always@(posedge sys_clk)//1000HZ
            begin
                if (cnt == 32'd50000)
                begin
                    debouncer_divclk <= ~debouncer_divclk;
                    cnt              <= 0;
                end
                else
                    cnt <= cnt+1'b1;
            end
        endmodule
            
            
            
            