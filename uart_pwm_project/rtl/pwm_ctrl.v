//======================================================
// Module: pwm_ctrl
// Wraps PWM + frequency scaler
//======================================================
module pwm_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire [1:0] pow2_cfg,
    input  wire [1:0] pow5_cfg,
    input  wire [6:0] duty_cfg, // 0..99
    input  wire       cfg_valid,
    output wire pwm_out
);

    // Duty register
    reg [6:0] duty_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            duty_reg <= 0;
        end else if (cfg_valid) begin
            if (duty_cfg < 100)
                duty_reg <= duty_cfg;
        end
    end

    // Frequency tick
    wire tick;
    freq_scale freq_div (
        .clk(clk),
        .rst(rst),
        .pow2_cfg(pow2_cfg),
        .pow5_cfg(pow5_cfg),
        .tick(tick)
    );

    // PWM generator
    pwm #(.WIDTH(16)) pwm_gen (
        .clk(clk),
        .rst(rst),
        .period(100),              // 100 ticks -> 1% resolution
        .duty(duty_reg),           // 0..99
        .pwm_out(pwm_out)
    );

endmodule
