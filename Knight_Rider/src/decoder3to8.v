module decoder3to8 (
    input  [2:0] sel,
    output reg [7:0] out
);
    always @(*) begin
        out = 8'b00000000;
        out[sel] = 1'b1;
    end
endmodule
