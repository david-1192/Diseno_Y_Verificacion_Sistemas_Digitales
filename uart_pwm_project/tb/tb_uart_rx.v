`timescale 1ns/1ps
//======================================================
// Testbench: tb_uart_rx
// Simula un byte recibido por UART (0x55 = 01010101b)
//======================================================
module tb_uart_rx;

    reg clk;
    reg rst;
    reg rx;
    wire [7:0] data_out;
    wire data_valid;

    // Parámetros UART
    localparam CLK_FREQ = 50000000;   // 50 MHz
    localparam BAUD     = 115200;
    localparam BAUD_DIV = CLK_FREQ / BAUD; // ~434

    // DUT
    uart_rx #(.BAUD_DIV(BAUD_DIV)) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // Clock 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20 ns periodo
    end

    // Tarea para enviar un byte serialmente
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start bit (0)
            rx = 0;
            #(BAUD_DIV*20);

            // 8 data bits (LSB primero)
            for (i=0; i<8; i=i+1) begin
                rx = data[i];
                #(BAUD_DIV*20);
            end

            // Stop bit (1)
            rx = 1;
            #(BAUD_DIV*20);
        end
    endtask

    // Estímulo principal
    initial begin
        // Dump waves
        $dumpfile("wave_uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        // Inicialización
        rx = 1; // línea en reposo = alto
        rst = 1;
        #200;
        rst = 0;

        // Espera un poco
        #2000;

        // Enviar 0x55 = 0101_0101
        $display("Enviando 0x55 ...");
        send_byte(8'h55);

        // Espera a que data_valid se active
        #100000;

        // Enviar 0xA3 = 1010_0011
        $display("Enviando 0xA3 ...");
        send_byte(8'hA3);

        #200000;

        $finish;
    end

endmodule
