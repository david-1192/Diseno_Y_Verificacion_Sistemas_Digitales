`timescale 1ns/1ps
// ============================================================================
// Top-level: UART -> RX Buffer -> cmd_parser -> PWM -> UART TX
// ============================================================================
module top (
    input  wire clk,
    input  wire rst,
    input  wire rx,          // UART entrada
    output wire tx,          // UART salida
    output wire pwm_out      // PWM salida
);

    // ---------------------------------------------------
    // Señales internas
    // ---------------------------------------------------
    wire [7:0] rx_data;
    wire       rx_valid;

    wire [7:0] buffer_out;
    wire       buffer_empty;
    wire       buffer_full;
    reg        buffer_rd_en;
    wire       eol_flag;

    wire [7:0] duty_cycle;
    wire [7:0] freq_div;
    wire       enable_pwm;

    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    // ---------------------------------------------------
    // UART RX
    // ---------------------------------------------------
    uart_rx #(.BAUD_DIV(434)) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // ---------------------------------------------------
    // RX Buffer (solo almacenamiento adicional)
    // ---------------------------------------------------
    rx_buffer rx_buffer_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(rx_valid),
        .wr_data(rx_data),
        .rd_en(buffer_rd_en),
        .rd_data(buffer_out),
        .full(buffer_full),
        .empty(buffer_empty),
        .end_of_str(eol_flag)
    );

    // ---------------------------------------------------
    // Command Parser (toma datos directos de RX)
    // ---------------------------------------------------
    cmd_parser cmd_parser_inst (
        .clk(clk),
        .rst(rst),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .duty_cycle(duty_cycle),
        .freq_div(freq_div),
        .enable_pwm(enable_pwm)
    );

    // ---------------------------------------------------
    // PWM Controller
    // ---------------------------------------------------
    pwm_ctrl pwm_ctrl_inst (
        .clk(clk),
        .rst(rst),
        .pow2_cfg(freq_div[1:0]), // por simplicidad
        .pow5_cfg(freq_div[3:2]),
        .duty_cfg(duty_cycle[6:0]),
        .cfg_valid(enable_pwm),
        .pwm_out(pwm_out)
    );

    // ---------------------------------------------------
    // UART TX (eco simple de RX)
    // ---------------------------------------------------
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 0;
            tx_data  <= 0;
        end else if (rx_valid && !tx_busy) begin
            tx_data  <= rx_data;   // eco del byte recibido
            tx_start <= 1;
        end else begin
            tx_start <= 0;
        end
    end

    // ---------------------------------------------------
    // Lectura automática del buffer (no usado por parser)
    // ---------------------------------------------------
    always @(*) begin
        buffer_rd_en = !buffer_empty;
    end

endmodule
