module baud_gen #(
    parameter CLK_FREQ = 25000000,   // Frecuencia del reloj de entrada (25 MHz)
    parameter BAUD_RATE = 115200     // Baud rate deseado
)(
    input  wire clk,
    input  wire rst,
    output reg  baud_tick
);

    localparam integer DIVISOR   = CLK_FREQ / BAUD_RATE;
    localparam integer CTR_WIDTH = $clog2(DIVISOR);

    reg [CTR_WIDTH-1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter   <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == DIVISOR-1) begin
                counter   <= 0;
                baud_tick <= 1;
            end else begin
                counter   <= counter + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule
