`timescale 1ns / 1ps
module lab4(
    input  clk,            // System clock at 100 MHz
    input  reset_n,        // System reset signal, in negative logic
    input  [3:0] usr_btn,  // Four user pushbuttons
    output [3:0] usr_led   // Four yellow LEDs
);

reg [4-1:0] counter = 0; // 4-bit counter register
wire [4-1:0] debounced;  // 4-bit debounced signals
wire pwm_signal;         // PWM 

// Instantiate the 'debounce_btn' module for each button            
debounce_btn DEB0(.clk(clk), .btn(usr_btn[0]), .deb(debounced[0]));
debounce_btn DEB1(.clk(clk), .btn(usr_btn[1]), .deb(debounced[1]));
debounce_btn DEB2(.clk(clk), .btn(usr_btn[2]), .deb(debounced[2]));
debounce_btn DEB3(.clk(clk), .btn(usr_btn[3]), .deb(debounced[3]));

// Instantiate the 'pwn' module
pwm PWM(.clk(clk),
        .btn_increase(debounced[3]),
        .btn_decrease(debounced[2]),
        .pwm_signal(pwm_signal));

// Assign the value of the counter to the LEDs whenever the pwm signal is high
assign usr_led = (pwm_signal==1) ? counter : 0;

always @ (posedge clk) begin
    if (!reset_n) counter <= 0; // reset the counter
    else if (debounced[0]) begin // when 'usr_btn[0]' is pressed 
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
    else if (debounced[1]) begin // when 'usr_btn[1]' is pressed
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
    input btn_increase,   // button that increases the duty cycle of the pwm
    input btn_decrease,   // button that decreases the duty cycle of the pwm
    output reg pwm_signal // output pwm signal
);

// 5 distincts duty cycles to implement
// duty cycles: 5% ,    25%,    50%,    75%,    100%

// I use a 40-bit register to store the different duty cycles we need to implement
// Inside we have the values: 5, 25, 50, 75 and 100. Each of them stored using 8 bits.
// The duty_index will increase and decrease between 0 and 4 inclusive. 

reg [40-1:0] duty_cycle = 40'b00000101_00011001_00110010_01001011_01100100;
integer duty_index = 2; // we will use this integer to slice through our duty_cycle register. It's set to 2 as default.

reg [20-1:0] pwm_counter = 0; // 20-bit counter

always @ (posedge clk) begin
    pwm_counter = pwm_counter + 1;

    if (pwm_counter>=20'b1111_0100_0010_0100_0000) // if the pwm_counter >= 10^6 we set it back to 0.
        pwm_counter = 0;                           // 10^6 because we want to generate a 100Hz signal
                                                   // corresponding to 10^6 clock ticks

    else if (pwm_counter < duty_cycle[(duty_index*8) +: 8]*10000) 
        pwm_signal = 1;

    else
        pwm_signal = 0;
end

always @ (posedge clk) begin // increase and decrease the duty_cycle by changing the duty_index
    if (btn_increase) begin
        duty_index = duty_index+1;
        if (duty_index>4) duty_index = 4;
    end
    else if (btn_decrease) begin
        duty_index = duty_index-1;
        if (duty_index<0) duty_index = 0;
    end
end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This debouncing module can get some improvements, but it worked just fine for me :)
module debounce_btn(
    input clk,
    input btn,       // input button signal   
    output reg deb   // output button signal after debouncing
);

// We set a 23-bit timer. I sticked with 23-bit after an exhausting trial-and-error process.
reg [23-1:0] timer = {23{1'b1}};   
 
always @ (posedge clk) begin // This big idea here is just to output the value of the button when the 
    if (timer == 0) begin    // timer runs out.
        deb <= btn;
        timer <= {23{1'b1}}; // One TA advised me to get rid of this line. It worked, so I left it.  
    end
    else begin
        if (btn) begin 
            timer <= timer - 1;
            deb <= 0;
        end
        else begin
            timer <= {23{1'b1}};
            deb <= 0;
        end
    end
end    

endmodule