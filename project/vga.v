//640*480
module vga_top (input clk,
                input debounced_power_on,
                input manul_mode_on,
                input semi_auto_mode_on,
                input auto_mode_on,
                input [26:0]record,
                input power_now,
                input rst_n,
                output reg hsync,
                output reg vsync,         // hsync and vsync are connected to the port on board.
                output reg [3:0] red,
                output reg [3:0] green,
                output reg [3:0] blue);   // color
    reg [9:0] hc;   // h_cnt
    reg [9:0] vc;
    reg [3:0] led1,led2,led3,led4,led5,led6,led7;
    reg has_record; // diffe
    wire has_color; // whether the pixel has color
    wire clk25;
    reg [3:0] digit; // store the current digit to display
    // x y store the coordinate in the valid zone
    reg [9:0]x;
    reg [9:0]y;
    reg [1:0] clk_counter;
    reg can_be_colored;
    wire clk_vga;
    num_switch num_switch(
    clk_vga,
    has_record,
    digit,
    y,
    x,
    has_color
    );
    parameter hpixels = 800;    // number of pixel of every horizontal line
    parameter hbp     = 144;       // left bound
    parameter hfp     = 783;       // reight bound, revised from 784
    parameter vbp     = 31;       // upper bound
    parameter vfp     = 510;       // lower bound
    
    parameter state_xs = 310;
    parameter state_xe = 330;
    parameter state_ys = 160;
    parameter state_ye = 192;
    parameter nums_xs1 = 240;
    parameter nums_xe1 = 260;
    parameter nums_xs2 = 260;
    parameter nums_xe2 = 280;
    parameter nums_xs3 = 280;
    parameter nums_xe3 = 300;
    parameter nums_xs4 = 300;
    parameter nums_xe4 = 320;
    parameter nums_xs5 = 320;
    parameter nums_xe5 = 340;
    parameter nums_xs6 = 340;
    parameter nums_xe6 = 360;
    parameter nums_xs7 = 360;
    parameter nums_xe7 = 380;
    parameter nums_xs8 = 380;
    parameter nums_xe8 = 400;
    parameter nums_ys  = 256;
    parameter nums_ye  = 288;
    
    // get the vga clock
    always@(posedge clk)
    begin
        begin
        clk_counter <= clk_counter+1'b1;
    end
    end
    assign clk_vga = clk_counter[1];

    // get the valid sign, storing if the current coordinate is okay to display color.
    reg valid_yr;       //行显示有效信�? only when ycnt in [32,510] it is 1.
    always @(posedge clk_vga )//480�?
        begin
           if(vc==10'd32)
                valid_yr<=1'b1;
            else if(vc==10'd511)
                valid_yr<=1'b0;
        end
    wire valid_y=valid_yr;   
    reg valid_r;
    always @(posedge clk_vga )//640�?
        begin
            if((hc==10'd141)&&valid_y)
                valid_r<=1'b1;
            else if((hc==10'd781)&&valid_y)
                valid_r<=1'b0;    
        end
    wire valid=valid_r; // valid store if the current coordintate is valid to display color
    
    
    always @(posedge clk_vga) begin
        if (hc == 10'd799)
        begin
            hc <= 10'd0;
        end
        else
        begin
            hc <= hc +1'b1;
        end
    end
    
    always @(posedge clk_vga) begin
        if (hc < 10'd96)  //ͬ��Ϊ96 96 is the sync time
            hsync <= 1'b0;
        else
            hsync <= 1'b1;
    end
    
    // update the index of current vertical line when the scan reach the end of a horizontal line
    always @(posedge clk_vga) begin
        if (hc == 799) // when the scan reach the end of a horizontal line
        begin
            if (vc == 10'd524) // revised from 520
                vc <= 10'd0;
            else
                vc <= vc + 1'b1;
        end
        else
            vc <= vc;
    end
    
    always @(posedge clk_vga) begin
        if (vc < 10'd2)   //ͬ��Ϊ2  2 is the sync time
            vsync <= 1'b0;
        else
            vsync <= 1'b1;
    end
    
    // always @(posedge clk_vga) begin
    //     if ((hc >= hbp) && (hc <= hfp) && (vc >= vbp) && (vc <= vfp))
    //     begin
    //         can_be_colored = 1'b1;
    //     end
    //     else
    //         can_be_colored = 1'b0;
    // end
    
    
    reg [2:0]color_index; // store the current color: 000:black 111:white
    always @(posedge clk_vga) begin
        case (debounced_power_on)
            0: begin
                has_record = 1'b0;
                if ((hc >= hbp+state_xs)&&(hc < hbp+state_xe)&&(vc >= vbp+state_ys)&&(vc < vbp+state_ye))
                begin
                    color_index <= 3'b100;
                end
                else
                begin
                    color_index <= 3'b000;
                end
            end
            default: begin
                case ({manul_mode_on,semi_auto_mode_on,auto_mode_on})
                    3'b100:
                    begin
                        if ((hc >= hbp+state_xs)&&(hc < hbp+state_xe)&&(vc >= vbp+state_ys)&&(vc < vbp+state_ye))
                        begin
                            has_record = 1'b0;
                            color_index <= 3'b110;
                        end
                        else
                        begin
                            if (rst_n&&power_now) begin
                                has_record = 1'b0;
                                color_index <= 3'b000;
                            end
                            else begin
                                has_record = 1'b1;
                                led7 <= (record/100_0000)%10;
                                led6 <= (record/10_0000)%10;
                                led5 <= (record/1_0000)%10;
                                led4 <= (record/1_000)%10;
                                led3 <= (record/100)%10;
                                led2 <= (record/10)%10;
                                led1 <= record%10;
                                
                                if ((hc >= hbp+nums_xs1)&&(hc < hbp+nums_xe1)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led7;
                                    x       <= hc-hbp-nums_xs1;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                end
                                else if ((hc >= hbp+nums_xs2)&&(hc < hbp+nums_xe2)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led6;
                                    x       <= hc-hbp-nums_xs2;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                end
                                    else if ((hc >= hbp+nums_xs3)&&(hc < hbp+nums_xe3)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led5;
                                    x       <= hc-hbp-nums_xs3;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                    end
                                    else if ((hc >= hbp+nums_xs4)&&(hc < hbp+nums_xe4)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led4;
                                    x       <= hc-hbp-nums_xs4;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                    end
                                    else if ((hc >= hbp+nums_xs5)&&(hc < hbp+nums_xe5)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led3;
                                    x       <= hc-hbp-nums_xs5;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                    end
                                    else if ((hc >= hbp+nums_xs6)&&(hc < hbp+nums_xe6)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led2;
                                    x       <= hc-hbp-nums_xs6;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                    end
                                    else if ((hc >= hbp+nums_xs7)&&(hc < hbp+nums_xe7)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= led1;
                                    x       <= hc-hbp-nums_xs7;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                    end
                                    else if ((hc >= hbp+nums_xs8)&&(hc < hbp+nums_xe8)&&(vc >= vbp+nums_ys)&&(vc < vbp+nums_ye)) begin
                                    digit   <= 4'b0;
                                    x       <= hc-hbp-nums_xs8;
                                    y       <= vc-vbp-nums_ys;
                                    color_index <= 3'b111;
                                    end
                                else begin
                                    color_index <= 3'b000;
                                end
                                
                            end
                        end
                    end
                    3'b010:
                    begin
                        has_record = 0;
                        if ((hc >= hbp+state_xs)&&(hc < hbp+state_xe)&&(vc >= vbp+state_ys)&&(vc < vbp+state_ye))
                        begin
                            color_index <= 3'b010;
                        end
                        else
                        begin
                            color_index <= 3'b000;
                        end
                    end
                    3'b001:
                    begin
                        has_record = 0;
                        if ((hc >= hbp+state_xs)&&(hc < hbp+state_xe)&&(vc >= vbp+state_ys)&&(vc < vbp+state_ye))
                        begin
                            color_index <= 3'b001;
                        end
                        else
                        begin
                            color_index <= 3'b000;
                        end
                    end
                    default:begin
                        has_record = 1'b0;
                        color_index <= 3'b000;
                    end
                endcase
            end
        endcase
    end
    
    always @(posedge clk_vga) begin // this block control color
        casex ({valid,color_index,has_record,has_color})
            6'b111111:
            begin
                red <= 4'b1111;
                green <= 4'b1111;
                blue <= 4'b1111;
            end 
            6'b1110xx:
            begin
                red <= 4'b1111;
                green <= 4'b1111;
                blue <= 4'b0000;
            end 
            6'b1100xx:
            begin
                red <= 4'b1111;
                green <= 4'b0000;
                blue <= 4'b0000;
            end
            6'b1010xx:
            begin
                red <= 4'b0000;
                green <= 4'b1111;
                blue <= 4'b0000;
            end
            6'b1001xx:
            begin
                red <= 4'b0000;
                green <= 4'b0000;
                blue <= 4'b1111;
            end
            default: 
            begin
                red <= 4'b0000;
                green <= 4'b0000;
                blue <= 4'b0000;
            end
        endcase
    end
endmodule
    