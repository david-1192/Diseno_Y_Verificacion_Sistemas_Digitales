module top (
    input wire clk,
    input wire rst,
    input wire rx,
    output reg match_pulse,
    output wire data_valid_debug,
    output wire data_bit_debug,
    output wire [3:0] last4_debug
);

    wire data_valid;
    wire data_bit;
    wire [3:0] last4;
    wire match_raw;

    uart_sampler u_sampler (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_valid(data_valid),
        .data_bit(data_bit)
    );

    sipo_reg u_sipo (
        .clk(clk),
        .rst(rst),
        .shift_en(data_valid),
        .data_in(data_bit),
        .last4(last4)
    );

    detector u_det (
        .data_in(last4),
        .match(match_raw)
    );

    reg sync_ff1, sync_ff2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_ff1 <= 0;
            sync_ff2 <= 0;
            match_pulse <= 0;
        end else begin
            sync_ff1 <= match_raw;
            sync_ff2 <= sync_ff1;
            match_pulse <= sync_ff1 & ~sync_ff2;
        end
    end

    assign data_valid_debug = data_valid;
    assign data_bit_debug   = data_bit;
    assign last4_debug      = last4;

endmodule
