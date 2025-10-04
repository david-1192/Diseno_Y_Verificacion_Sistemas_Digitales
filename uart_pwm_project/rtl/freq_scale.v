//======================================================
// Module: freq_scale
// Frequency divider for PWM base clock
// f_pwm = 50kHz / (2^POW2 * 5^POW5)
//======================================================
module freq_scale (
    input  wire clk,       // 50 MHz
    input  wire rst,
    input  wire [1:0] pow2_cfg, // 0..3
    input  wire [1:0] pow5_cfg, // 0..3
    output reg  tick       // single-cycle enable pulse
);

    // Compute divisor dynamically
    integer div_factor;
    integer counter;

    always @(*) begin
        div_factor = (1 << pow2_cfg) * (pow5_cfg == 0 ? 1 :
                      (pow5_cfg == 1 ? 5 :
                      (pow5_cfg == 2 ? 25 : 125)));
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick <= 0;
        end else begin
            if (counter == (1000*div_factor - 1)) begin
                counter <= 0;
                tick <= 1;
            end else begin
                counter <= counter + 1;
                tick <= 0;
            end
        end
    end

endmodule
