`timescale 1ns/1ps
module tb_decoder3to8;
    reg [2:0] sel;
    wire [7:0] out;

    decoder3to8 uut (
        .sel(sel),
        .out(out)
    );

    initial begin
        $dumpfile("../waves/decoder3to8.vcd");
        $dumpvars(0, tb_decoder3to8);

        sel = 3'b000;
        repeat (8) begin
            #10 sel = sel + 1;
        end
        #20 $finish;
    end
endmodule
