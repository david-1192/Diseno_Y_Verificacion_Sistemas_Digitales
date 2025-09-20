module sipo_reg (
    input wire clk,
    input wire rst,
    input wire shift_en,
    input wire data_in,
    output wire [3:0] last4
);

    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            shift_reg <= 0;
        else if (shift_en)
            shift_reg <= {shift_reg[6:0], data_in};
    end

    assign last4 = shift_reg[3:0];

endmodule
