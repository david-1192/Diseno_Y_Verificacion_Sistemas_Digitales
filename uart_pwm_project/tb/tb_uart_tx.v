`timescale 1ns/1ps

module tb_uart_tx;

    // Parámetros de simulación
    localparam CLK_FREQ = 50_000_000;
    localparam BAUD     = 115200;
    localparam BAUD_DIV = CLK_FREQ / BAUD; // ~434

    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] data_in;
    wire tx;
    wire tx_busy;

    // DUT
    uart_tx #(.BAUD_DIV(BAUD_DIV)) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock 50 MHz
    initial clk = 0;
    always #10 clk = ~clk;  // 20ns periodo → 50 MHz

    // Stimulus
    initial begin
        $dumpfile("wave_uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        // Reset
        rst = 1; tx_start = 0; data_in = 8'h00;
        #100;
        rst = 0;

        // Enviar primer byte (0x55 = 0101_0101)
        @(negedge clk);
        data_in = 8'h55;
        tx_start = 1;
        @(negedge clk);
        tx_start = 0;

        // Esperar a que termine la transmisión
        wait(!tx_busy);
        #1000;

        // Enviar segundo byte (0xA3 = 1010_0011)
        @(negedge clk);
        data_in = 8'hA3;
        tx_start = 1;
        @(negedge clk);
        tx_start = 0;

        wait(!tx_busy);
        #2000;

        $finish;
    end

endmodule
