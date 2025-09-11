module counter4 (
    input clk,
    input reset,
    input enable,
    input dir,              // 0 = ascendente, 1 = descendente
    output reg [3:0] count
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0000;
        else if (enable) begin
            if (!dir) begin
                if (count < 4'd7) count <= count + 1;
                else count <= count; // saturación en 7
            end else begin
                if (count > 0) count <= count - 1;
                else count <= count; // saturación en 0
            end
        end
    end
endmodule
