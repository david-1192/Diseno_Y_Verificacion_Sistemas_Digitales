`timescale 1ns/1ps

module tb_top;

    // Señales
    reg clk;
    reg rst;
    reg rx;
    wire tx;
    wire pwm_out;

    // Instancia del DUT (Device Under Test)
    top dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .pwm_out(pwm_out)
    );

    // Generación de clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz
    end

    // Reset
    initial begin
        rst = 1;
        rx = 1;   // línea idle en UART es '1'
        #100;
        rst = 0;
    end

    // -----------------------------------------------------
    // Task para enviar un byte por UART a "rx"
    // -----------------------------------------------------
    task send_uart;
        input [7:0] data_in;
        integer i;
        begin
            // Start bit
            rx = 0;
            #(8680);   // 1 bit @ 115200 baudios (con clk=50MHz, divisor ~434)

            // Data bits (LSB primero)
            for (i = 0; i < 8; i = i+1) begin
                rx = data_in[i];
                #(8680);
            end

            // Stop bit
            rx = 1;
            #(8680);
        end
    endtask

    // -----------------------------------------------------
    // Estímulos
    // -----------------------------------------------------
    initial begin
        @(negedge rst); // esperar a que termine reset
        #20000;

        // Ejemplo de comandos enviados por UART:
        // Supongamos que el parser espera algo como "D50\n" (duty 50%)
        send_uart("D");
        send_uart("5");
        send_uart("0");
        send_uart("\n");

        #200000;

        // Otro ejemplo: duty 80%
        send_uart("D");
        send_uart("8");
        send_uart("0");
        send_uart("\n");

        #200000;

        $finish;
    end

    // -----------------------------------------------------
    // Dumpfile para GTKWave
    // -----------------------------------------------------
    initial begin
        $dumpfile("wave_top.vcd");  // nombre del archivo VCD
        $dumpvars(0, tb_top);       // volcar todas las señales del testbench y DUT
    end

endmodule
