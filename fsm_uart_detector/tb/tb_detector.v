`timescale 1ns/1ps

module tb_detector;

    reg [3:0] data_in;
    wire match;

    detector dut (
        .data_in(data_in),
        .match(match)
    );

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, tb_detector);

        data_in = 4'b0000; #50;
        data_in = 4'b0101; #50;
        data_in = 4'b1111; #50;
        data_in = 4'b0101; #50;
        data_in = 4'b1010; #50;

        #200;
        $finish;
    end

endmodule
