`timescale 1ns/1ps

module tb_top;

    reg clk = 0;
    reg rst = 0;
    reg rx = 1;
    wire match_pulse;
    wire data_valid_debug;
    wire data_bit_debug;
    wire [3:0] last4_debug;

    localparam CLK_FREQ = 25_000_000;
    localparam BAUD_RATE = 115200;
    localparam BIT_PERIOD = 1_000_000_000 / BAUD_RATE;

    top uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .match_pulse(match_pulse),
        .data_valid_debug(data_valid_debug),
        .data_bit_debug(data_bit_debug),
        .last4_debug(last4_debug)
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
        $dumpvars(0, tb_top);

        rst = 1; #200; rst = 0;

        #(BIT_PERIOD*2);

        // Patrón: 0111 (no match), 0101 (match esperado), etc.
        send_byte(8'b10100101); // LSB = 0101
        #(BIT_PERIOD*5);

        send_byte(8'b11110101); // también contiene 0101
        #(BIT_PERIOD*5);

        $finish;
    end

endmodule
