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

pwm PWM(.clk(clk),
        .btn_increase(debounced[2]),
        .btn_decrease(debounced[3]),
        .pwm_signal(pwm_signal));
        
//debounce DBC(.clk(clk),
////             .pwm(pwm_signal),
//             //.reset(reset_n),
//             .usr_btn(usr_btn),
//             .debounced(debounced));
             
debounce_btn0 DEB0(.clk(clk), .btn0(usr_btn[0]), .deb0(debounced[0]));
debounce_btn1 DEB1(.clk(clk), .btn1(usr_btn[1]), .deb1(debounced[1]));
debounce_btn2 DEB2(.clk(clk), .btn2(usr_btn[2]), .deb2(debounced[2]));
debounce_btn3 DEB3(.clk(clk), .btn3(usr_btn[3]), .deb3(debounced[3]));
            
assign usr_led = counter;

always @ (posedge clk) begin
    if (!reset_n) counter <= 0;
    else if (debounced[0]) begin
//        counter <= 4'b1010;
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
//        counter <= 4'b0011;
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
//    input reset,
    input btn_increase,
    input btn_decrease,
    output reg pwm_signal
);

// duty cycles: 5% ,    25%,    50%,    75%,    100%

reg [40-1:0] duty_cycle = 40'b0000_0101_0001_1001_0011_0010_0100_1011_0110_0100;
integer duty_index = 2;

reg [8-1:0] pwm_counter = 0;

always @ (posedge clk) begin
    if (pwm_counter < duty_cycle[(duty_index*8) +: 8]) begin
        pwm_counter <= pwm_counter + 1;
        pwm_signal <= 1;
    end
    else begin
        pwm_signal <= 0;
        pwm_counter <= 0;
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
module debounce(
    input clk,
//    input pwm,
    input [4-1:0] usr_btn,
    output reg [4-1:0] debounced
 );
   
 reg [3:0] timer = 3'b111;
 
 always @ (posedge clk) begin //usr_btn[0], usr_btn[1], usr_btn[2], usr_btn[3]) begin
    
// end
 
// always @ (posedge clk) begin
    if (timer == 0) begin
        debounced[0] <= usr_btn[0];
        debounced[1] <= usr_btn[1];
        debounced[2] <= usr_btn[2];
        debounced[3] <= usr_btn[3];
        timer <= 3'b111;
    end
    else begin
        if (usr_btn[0] | usr_btn[1] | usr_btn[2] | usr_btn[3])
            timer <= timer - 1;
        else if (!usr_btn[0] & !usr_btn[1] & !usr_btn[2] & !usr_btn[3]) timer <= 3'b111;
    end
 end 

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module debounce_btn0(
    input clk,
    input btn0,
    output reg deb0);

reg [3:0] timer = 3'b111;
 
 always @ (posedge clk) begin
    if (timer == 0) begin
        deb0 = 1;
        timer = 3'b111;
        deb0 = 0;
    end
    else begin
        if (btn0) begin 
            timer <= timer - 1;
            deb0 <= 0;
        end
        else begin
            timer <= 3'b111;
            deb0 <= 0;
        end
    end
 end    

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module debounce_btn1(
    input clk,
    input btn1,
    output reg deb1);

reg [3:0] timer = 3'b111;
 
 always @ (posedge clk) begin
    if (timer == 0) begin
        deb1 <= btn1;
        timer <= 3'b111;
    end
    else begin
        if (btn1) begin 
            timer <= timer - 1;
            deb1 <= 0;
        end
        else begin
            timer <= 3'b111;
            deb1 <= 0;
        end
    end
 end    

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module debounce_btn2(
    input clk,
    input btn2,
    output reg deb2);

reg [3:0] timer = 3'b111;
 
 always @ (posedge clk) begin
    if (timer == 0) begin
        deb2 <= btn2;
        timer <= 3'b111;
    end
    else begin
        if (btn2) begin 
            timer <= timer - 1;
            deb2 <= 0;
        end
        else begin
            timer <= 3'b111;
            deb2 <= 0;
        end
    end
 end    

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module debounce_btn3(
    input clk,
    input btn3,
    output reg deb3);

reg [3:0] timer = 3'b111;
 
 always @ (posedge clk) begin
    if (timer == 0) begin
        deb3 <= btn3;
        timer <= 3'b111;
    end
    else begin
        if (btn3) begin 
            timer <= timer - 1;
            deb3 <= 0;
        end
        else begin
            timer <= 3'b111;
            deb3 <= 0;
        end
    end
 end    

endmodule