//======================================================
// Module: pwm
// Center-aligned PWM generator
// Parameters:
//   - period: total number of ticks per cycle
//   - duty  : duty cycle value (0..period-1)
//======================================================
module pwm #(
    parameter WIDTH = 16  // counter width
)(
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] period,
    input  wire [WIDTH-1:0] duty,
    output reg  pwm_out
);

    reg [WIDTH-1:0] cnt;
    reg dir; // 0 = up, 1 = down (triangle counter)

    // Triangle counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            dir <= 0;
        end else begin
            if (!dir) begin
                if (cnt == period) begin
                    dir <= 1;
                    cnt <= cnt - 1;
                end else begin
                    cnt <= cnt + 1;
                end
            end else begin
                if (cnt == 0) begin
                    dir <= 0;
                    cnt <= cnt + 1;
                end else begin
                    cnt <= cnt - 1;
                end
            end
        end
    end

    // Compare
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pwm_out <= 0;
        end else begin
            pwm_out <= (cnt < duty);
        end
    end

endmodule
