`timescale 1ns/1ps
//======================================================
// UART Receiver
// Parameters: BAUD_DIV = (CLK_FREQ / BAUD_RATE)
//======================================================
module uart_rx #(
    parameter BAUD_DIV = 434 // ejemplo: 50 MHz / 115200 ≈ 434
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,            // Línea serial
    output reg  [7:0] data_out,
    output reg  data_valid
);

    // Estados del FSM
    localparam IDLE   = 0,
               START  = 1,
               DATA   = 2,
               STOP   = 3;

    reg [1:0] state;
    reg [3:0] bit_index;
    reg [15:0] baud_cnt;
    reg [7:0] data_buf;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_index <= 0;
            baud_cnt <= 0;
            data_out <= 0;
            data_buf <= 0;
            data_valid <= 0;
        end else begin
            data_valid <= 0; // por defecto en 0

            case (state)
                IDLE: begin
                    if (~rx) begin
                        // Detecta start bit (rx = 0)
                        state <= START;
                        baud_cnt <= 0;
                    end
                end

                START: begin
                    if (baud_cnt == (BAUD_DIV/2)) begin
                        // Muestra en el centro del start bit
                        if (~rx) begin
                            state <= DATA;
                            baud_cnt <= 0;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE; // falso start
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                DATA: begin
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        data_buf[bit_index] <= rx;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end
                        bit_index <= bit_index + 1;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                STOP: begin
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        if (rx) begin
                            data_out <= data_buf;
                            data_valid <= 1;
                        end
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule
