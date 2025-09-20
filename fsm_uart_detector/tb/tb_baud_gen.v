`timescale 1ns/1ps

module tb_baud_gen;

    reg clk = 0;
    reg rst = 0;
    wire baud_tick;

    baud_gen #(
        .CLK_FREQ(25_000_000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    always #20 clk = ~clk; // 25 MHz

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, tb_baud_gen);

        rst = 1; #200; rst = 0;
        #2000000;   // 2 ms
        $finish;
    end

endmodule
