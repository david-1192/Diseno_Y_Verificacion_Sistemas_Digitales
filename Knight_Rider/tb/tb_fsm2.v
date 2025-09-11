`timescale 1ns/1ps
module tb_fsm2;
    reg clk, reset;
    reg [3:0] count;
    wire dir;

    fsm2 uut (
        .clk(clk),
        .reset(reset),
        .count(count),
        .dir(dir)
    );

    initial begin
        $dumpfile("../waves/fsm2.vcd");
        $dumpvars(0, tb_fsm2);

        clk = 0; reset = 1; count = 0;
        #10 reset = 0;

        // Simular el barrido de un contador
        repeat (16) begin
            #10 count = count + 1;
        end

        // Simular el regreso descendente
        repeat (16) begin
            #10 count = count - 1;
        end

        #50 $finish;
    end

    always #5 clk = ~clk;
endmodule
