// rx_buffer.v
// Buffer circular para UART RX con 32 bytes de profundidad

module rx_buffer #(
    parameter DEPTH = 32,
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              wr_en,
    input  wire [WIDTH-1:0]  wr_data,
    input  wire              rd_en,
    output reg  [WIDTH-1:0]  rd_data,
    output wire              full,
    output wire              empty,
    output reg               end_of_str // se activa al recibir '\n' (0x0A)
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wr_ptr, rd_ptr, count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            end_of_str <= 0;
        end else begin
            end_of_str <= 0;
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;
                if (wr_data == 8'h0A) // detecta fin de string
                    end_of_str <= 1;
            end
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr  <= rd_ptr + 1;
                count   <= count - 1;
            end
        end
    end

endmodule
