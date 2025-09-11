`timescale 1ns/1ps
module tb_knight_rider;
    reg clk, reset, enable;
    wire [7:0] leds;

    knight_rider uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .leds(leds)
    );

    initial begin
        $dumpfile("../waves/knight_rider.vcd");
        $dumpvars(0, tb_knight_rider);

        clk = 0; reset = 1; enable = 0;
        #10 reset = 0; enable = 1;

        #500 $finish;
    end

    always #5 clk = ~clk; // reloj
endmodule
