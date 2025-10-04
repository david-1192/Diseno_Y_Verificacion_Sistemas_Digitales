`timescale 1ns/1ps

module tb_cmd_parser;

    // Señales del DUT
    reg clk;
    reg rst;
    reg rx_valid;
    reg [7:0] rx_data;

    wire [7:0] duty_cycle;
    wire [7:0] freq_div;
    wire       enable_pwm;

    // Instancia del DUT
    cmd_parser dut (
        .clk(clk),
        .rst(rst),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .duty_cycle(duty_cycle),
        .freq_div(freq_div),
        .enable_pwm(enable_pwm)
    );

    // Generador de clock
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Estímulos
    initial begin
        $dumpfile("wave_cmd_parser.vcd");
        $dumpvars(0, tb_cmd_parser);

        // Reset
        rst = 1;
        rx_valid = 0;
        rx_data = 8'd0;
        #20;
        rst = 0;

        // Enviar comando Duty ("D") + valor 128
        send_cmd("D", 8'd128);
        #40;

        // Enviar comando Freq ("F") + valor 10
        send_cmd("F", 8'd10);
        #40;

        // Enviar comando Enable ("E") + valor 1
        send_cmd("E", 8'd1);
        #40;

        // Enviar comando Disable ("E") + valor 0
        send_cmd("E", 8'd0);
        #40;

        $finish;
    end

    // Task para enviar comandos
    task send_cmd(input [7:0] cmd, input [7:0] value);
    begin
        @(posedge clk);
        rx_valid <= 1;
        rx_data  <= cmd;
        @(posedge clk);
        rx_valid <= 1;
        rx_data  <= value;
        @(posedge clk);
        rx_valid <= 0;
        rx_data  <= 0;
    end
    endtask

endmodule
