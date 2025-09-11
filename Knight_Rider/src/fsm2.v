module fsm2 (
    input clk,
    input reset,
    input [3:0] count,
    output reg dir
);
    // Estados
    parameter LEFT  = 1'b0;
    parameter RIGHT = 1'b1;

    reg state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= LEFT;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            LEFT:  next_state = (count == 4'd7) ? RIGHT : LEFT;
            RIGHT: next_state = (count == 4'd0) ? LEFT  : RIGHT;
            default: next_state = LEFT;
        endcase
    end

    always @(*) begin
        case (state)
            LEFT:  dir = 1'b0;
            RIGHT: dir = 1'b1;
            default: dir = 1'b0;
        endcase
    end
endmodule
