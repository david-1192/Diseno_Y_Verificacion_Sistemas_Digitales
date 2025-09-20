`timescale 1ns/1ps

module tb_uart_sampler;

    reg clk = 0;
    reg rst = 0;
    reg rx = 1;
    wire data_valid;
    wire data_bit;

    localparam CLK_FREQ = 25_000_000;
    localparam BAUD_RATE = 115200;
    localparam BIT_PERIOD = 1_000_000_000 / BAUD_RATE;

    uart_sampler #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_valid(data_valid),
        .data_bit(data_bit)
    );

    always #20 clk = ~clk;

    task send_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 0; #(BIT_PERIOD);
            for (i=0; i<8; i=i+1) begin
                rx = data[i];
                #(BIT_PERIOD);
            end
            rx = 1; #(BIT_PERIOD);
        end
    endtask

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, tb_uart_sampler);

        rst = 1; #200; rst = 0;

        #(BIT_PERIOD*2);
        send_byte(8'b10100101);
        #(BIT_PERIOD*5);

        $finish;
    end

endmodule
