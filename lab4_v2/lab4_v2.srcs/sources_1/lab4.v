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
        
debounce DBC(.clk(clk),
//             .pwm(pwm_signal),
             //.reset(reset_n),
             .usr_btn(usr_btn),
             .debounced(debounced));
            
assign usr_led = counter;

always @ (posedge clk) begin
    if (!reset_n) counter <= 0;
    else if (debounced[0]) begin
        counter <= counter-1;
        if (counter<-8) counter <= -8;
    end
    else if (debounced[1]) begin
        counter <= counter+1;
        if (counter>7) counter <= 7;
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
   
 reg [3:0] timer = 4'b1111;
 
 always @ (posedge clk) begin //usr_btn[0], usr_btn[1], usr_btn[2], usr_btn[3]) begin
    
// end
 
// always @ (posedge clk) begin
    if (timer == 0) begin
        debounced[0] <= usr_btn[0];
        debounced[1] <= usr_btn[1];
        debounced[2] <= usr_btn[2];
        debounced[3] <= usr_btn[3];
        timer <= 4'b1111;
    end
    else 
        timer <= timer - 1;
 end 

endmodule