`timescale 1ns/1ps
module tb_counter4;
    reg clk, reset, enable, dir;
    wire [3:0] count;

    counter4 uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .dir(dir),
        .count(count)
    );

    initial begin
        $dumpfile("../waves/counter4.vcd");
        $dumpvars(0, tb_counter4);

        clk = 0; reset = 1; enable = 0; dir = 0;
        #10 reset = 0; enable = 1;

        // Conteo ascendente
        dir = 0;
        #100;

        // Conteo descendente
        dir = 1;
        #100;

        // Reinicio
        reset = 1;
        #10 reset = 0;

        #50 $finish;
    end

    always #5 clk = ~clk; // reloj
endmodule
