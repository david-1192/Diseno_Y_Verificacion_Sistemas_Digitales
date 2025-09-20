`timescale 1ns/1ps

module tb_sipo_reg;

    reg clk = 0;
    reg rst;
    reg shift_en;
    reg data_in;
    wire [3:0] last4;

    sipo_reg dut (
        .clk(clk),
        .rst(rst),
        .shift_en(shift_en),
        .data_in(data_in),
        .last4(last4)
    );

    always #20 clk = ~clk;

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, tb_sipo_reg);

        rst = 1; shift_en = 0; data_in = 0;
        #100; rst = 0;

        shift_en = 1;
        data_in = 1; #40;
        data_in = 0; #40;
        data_in = 1; #40;
        data_in = 0; #40;
        data_in = 1; #40;
        data_in = 0; #40;
        data_in = 1; #40;
        data_in = 0; #40;
        shift_en = 0;

        #500;
        $finish;
    end

endmodule
