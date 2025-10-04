`timescale 1ns/1ps

module tb_rx_buffer;

    // Señales
    reg clk;
    reg rst;
    reg wr_en;
    reg [7:0] wr_data;
    reg rd_en;
    wire [7:0] rd_data;
    wire full;
    wire empty;
    wire end_of_str;

    // DUT
    rx_buffer #(.DEPTH(32), .WIDTH(8)) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .end_of_str(end_of_str)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Estímulos
    initial begin
        $dumpfile("wave_rx_buffer.vcd");
        $dumpvars(0, tb_rx_buffer);

        // Reset
        rst = 1;
        wr_en = 0; rd_en = 0; wr_data = 0;
        #20;
        rst = 0;

        // Escribir algunos bytes
        write_byte("H");
        write_byte("O");
        write_byte("L");
        write_byte("A");
        write_byte("\n");  // genera end_of_str
        #20;

        // Leer todos los bytes
        repeat (5) begin
            read_byte();
        end

        #50;
        $finish;
    end

    // Task: escribir un byte en el buffer
    task write_byte(input [7:0] b);
    begin
        @(posedge clk);
        wr_data <= b;
        wr_en   <= 1;
        @(posedge clk);
        wr_en   <= 0;
    end
    endtask

    // Task: leer un byte del buffer
    task read_byte;
    begin
        @(posedge clk);
        rd_en <= 1;
        @(posedge clk);
        rd_en <= 0;
        $display("Leído: %c (0x%0h)", rd_data, rd_data);
    end
    endtask

endmodule
