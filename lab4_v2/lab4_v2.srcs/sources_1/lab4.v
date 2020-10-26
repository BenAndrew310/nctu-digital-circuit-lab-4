`timescale 1ns / 1ps
module lab4(
  input  clk,            // System clock at 100 MHz
  input  reset_n,        // System reset signal, in negative logic
  input  [3:0] usr_btn,  // Four user pushbuttons
  output [3:0] usr_led   // Four yellow LEDs
);

reg [4-1:0] counter = 0;
wire [4-1:0] debounced;
wire pwm_signal;
            
debounce_btn1 DEB0(.clk(clk), .btn1(usr_btn[0]), .deb1(debounced[0]));
debounce_btn1 DEB1(.clk(clk), .btn1(usr_btn[1]), .deb1(debounced[1]));
debounce_btn1 DEB2(.clk(clk), .btn1(usr_btn[2]), .deb1(debounced[2]));
debounce_btn1 DEB3(.clk(clk), .btn1(usr_btn[3]), .deb1(debounced[3]));

pwm PWM(.clk(clk),
        .btn_increase(debounced[2]),
        .btn_decrease(debounced[3]),
        .pwm_signal(pwm_signal));

assign usr_led = (pwm_signal==1) ? counter : 0;

always @ (posedge clk) begin
    if (!reset_n) counter <= 0;
    else if (debounced[0]) begin
        case (counter)
            4'b0111: counter = 4'b0110;
            4'b0110: counter = 4'b0101;
            4'b0101: counter = 4'b0100;
            4'b0100: counter = 4'b0011;
            4'b0011: counter = 4'b0010;
            4'b0010: counter = 4'b0001;
            4'b0001: counter = 4'b0000;
            4'b0000: counter = 4'b1111;
            4'b1111: counter = 4'b1110;
            4'b1110: counter = 4'b1101;
            4'b1101: counter = 4'b1100;
            4'b1100: counter = 4'b1011;
            4'b1011: counter = 4'b1010;
            4'b1010: counter = 4'b1001;
            4'b1001: counter = 4'b1000;
            4'b1000: counter = 4'b1000;
            default: counter = 4'b0000; 
        endcase
    end
    else if (debounced[1]) begin
        case (counter)
            4'b0111: counter = 4'b0111;
            4'b0110: counter = 4'b0111;
            4'b0101: counter = 4'b0110;
            4'b0100: counter = 4'b0101;
            4'b0011: counter = 4'b0100;
            4'b0010: counter = 4'b0011;
            4'b0001: counter = 4'b0010;
            4'b0000: counter = 4'b0001;
            4'b1111: counter = 4'b0000;
            4'b1110: counter = 4'b1111;
            4'b1101: counter = 4'b1110;
            4'b1100: counter = 4'b1101;
            4'b1011: counter = 4'b1100;
            4'b1010: counter = 4'b1011;
            4'b1001: counter = 4'b1010;
            4'b1000: counter = 4'b1001;
            default: counter = 4'b0000; 
        endcase
    end
end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pwm(
    input clk,
    input btn_increase,
    input btn_decrease,
    output reg pwm_signal
);

// duty cycles: 5% ,    25%,    50%,    75%,    100%

reg [40-1:0] duty_cycle = 40'b00000101_00011001_00110010_01001011_01100100;
integer duty_index = 2;

reg [20-1:0] pwm_counter = 0;

always @ (posedge clk) begin
     pwm_counter = pwm_counter + 1;
    if (pwm_counter>=20'b1111_0100_0010_0100_0000) begin
        pwm_counter = 0;
    end
    else if (pwm_counter < duty_cycle[(duty_index*8) +: 8]*10000) begin
       
        pwm_signal = 1;
    end
    else begin
        pwm_signal = 0;
    end
end

always @ (posedge clk) begin
    if (btn_increase) begin
        duty_index = duty_index+1;
        if (duty_index>=5) duty_index = 4;
    end
    else if (btn_decrease) begin
        duty_index = duty_index-1;
        if (duty_index<0) duty_index = 0;
    end
end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module debounce_btn1(
    input clk,
    input btn1,
    output reg deb1);

reg [23-1:0] timer = {23{1'b1}};
 
 always @ (posedge clk) begin
    if (timer == 0) begin
        deb1 <= btn1;
        timer <= {23{1'b1}};
    end
    else begin
        if (btn1) begin 
            timer <= timer - 1;
            deb1 <= 0;
        end
        else begin
            timer <= {23{1'b1}};
            deb1 <= 0;
        end
    end
 end    

endmodule