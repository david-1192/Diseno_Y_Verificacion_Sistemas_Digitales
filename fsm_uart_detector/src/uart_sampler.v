module uart_sampler #(
    parameter CLK_FREQ = 25_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output reg  data_valid,
    output reg  data_bit
);

    localparam integer BAUD_TICKS = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_TICKS = BAUD_TICKS / 2;

    localparam [1:0] S_IDLE  = 2'b00,
                     S_START = 2'b01,
                     S_DATA  = 2'b10,
                     S_STOP  = 2'b11;

    reg [1:0] state;
    reg [15:0] tick_cnt;
    reg [3:0] bit_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            tick_cnt <= 0;
            bit_cnt <= 0;
            data_valid <= 0;
            data_bit <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    data_valid <= 0;
                    if (~rx) begin
                        state <= S_START;
                        tick_cnt <= 0;
                    end
                end
                S_START: begin
                    if (tick_cnt == HALF_TICKS) begin
                        state <= S_DATA;
                        tick_cnt <= 0;
                        bit_cnt <= 0;
                    end else tick_cnt <= tick_cnt + 1;
                end
                S_DATA: begin
                    if (tick_cnt == BAUD_TICKS-1) begin
                        tick_cnt <= 0;
                        data_bit <= rx;
                        data_valid <= 1;
                        if (bit_cnt == 7)
                            state <= S_STOP;
                        bit_cnt <= bit_cnt + 1;
                    end else begin
                        tick_cnt <= tick_cnt + 1;
                        data_valid <= 0;
                    end
                end
                S_STOP: begin
                    if (tick_cnt == BAUD_TICKS-1) begin
                        tick_cnt <= 0;
                        state <= S_IDLE;
                    end else tick_cnt <= tick_cnt + 1;
                    data_valid <= 0;
                end
            endcase
        end
    end

endmodule
