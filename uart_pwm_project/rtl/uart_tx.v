`timescale 1ns/1ps
//======================================================
// UART Transmitter
// Transmite un byte serialmente a 115200 baudios.
// Parámetros:
//   BAUD_DIV = CLK_FREQ / BAUD   (para 50MHz/115200 ≈ 434)
// Entradas:
//   clk        - reloj principal (50 MHz)
//   rst        - reset síncrono
//   tx_start   - pulso 1 ciclo: inicia transmisión de data_in
//   data_in    - byte a transmitir
// Salidas:
//   tx         - línea UART (reposo=1)
//   tx_busy    - activo durante transmisión
//======================================================
module uart_tx #(
    parameter BAUD_DIV = 434   // 50MHz / 115200 ≈ 434
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        tx_busy
);

    // Estados
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;
    reg [8:0] shifter;      // incluye 8 bits de datos + stop
    reg [9:0] baud_cnt;     // contador de baud
    reg [3:0] bit_idx;      // índice de bits transmitidos

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            tx       <= 1'b1; // reposo = 1
            tx_busy  <= 1'b0;
            baud_cnt <= 0;
            bit_idx  <= 0;
            shifter  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        // Preparar shifter: {stop_bit, data[7:0], start_bit}
                        shifter <= {1'b1, data_in, 1'b0};
                        state   <= START;
                        tx_busy <= 1'b1;
                        baud_cnt <= 0;
                        bit_idx <= 0;
                    end
                end

                START, DATA, STOP: begin
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        tx       <= shifter[0];
                        shifter  <= {1'b1, shifter[8:1]}; // shift con relleno stop
                        bit_idx  <= bit_idx + 1;
                        if (bit_idx == 9) begin
                            state <= IDLE;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule
