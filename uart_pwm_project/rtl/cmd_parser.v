`timescale 1ns/1ps

// ============================================================================
// Módulo: cmd_parser
// Descripción:
//   Decodifica comandos recibidos por UART y genera señales de control para
//   el PWM y la frecuencia. Genera un pulso de enable_pwm (cfg_valid) cada
//   vez que se recibe un comando válido.
// ============================================================================
module cmd_parser #(
    parameter CMD_WIDTH = 8
)(
    input  wire        clk,
    input  wire        rst,

    // Interfaz UART RX
    input  wire        rx_valid,
    input  wire [7:0]  rx_data,

    // Señales de control al PWM
    output reg  [7:0]  duty_cycle,   // Ciclo de trabajo
    output reg  [7:0]  freq_div,     // Escalador de frecuencia
    output reg         enable_pwm    // Pulso cfg_valid para pwm_ctrl
);

    // =========================================================================
    // Estados del parser
    // =========================================================================
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        CMD   = 2'b01,
        DATA  = 2'b10
    } state_t;

    state_t state, next_state;

    // =========================================================================
    // Variables internas
    // =========================================================================
    reg [7:0] cmd_reg;
    reg [7:0] data_reg;

    // =========================================================================
    // Máquina de estados
    // =========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            cmd_reg     <= 8'd0;
            data_reg    <= 8'd0;
            duty_cycle  <= 8'd0;
            freq_div    <= 8'd1;
            enable_pwm  <= 1'b0;
        end else begin
            state <= next_state;
            enable_pwm <= 1'b0;   // 🔴 por defecto en 0, se activa solo 1 ciclo

            if (rx_valid) begin
                case (state)
                    IDLE: begin
                        cmd_reg <= rx_data;
                    end
                    DATA: begin
                        data_reg <= rx_data;
                        case (cmd_reg)
                            "D": duty_cycle <= rx_data;    // Duty cycle
                            "F": freq_div   <= rx_data;    // Frecuencia
                            "E": ; // Solo usaría enable_pwm como flag manual
                        endcase
                        enable_pwm <= 1'b1; // 🔴 Pulso de validación
                    end
                endcase
            end
        end
    end

    // =========================================================================
    // Lógica de transición de estados
    // =========================================================================
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:  if (rx_valid) next_state = CMD;
            CMD:   if (rx_valid) next_state = DATA;
            DATA:  next_state = IDLE;
        endcase
    end

endmodule
