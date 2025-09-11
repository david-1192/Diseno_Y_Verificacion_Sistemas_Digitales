module knight_rider (
    input clk,
    input reset,
    input enable,
    output [7:0] leds
);
    wire [3:0] count;
    wire dir;

    counter4 U1 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .dir(dir),
        .count(count)
    );

    fsm2 U2 (
        .clk(clk),
        .reset(reset),
        .count(count),
        .dir(dir)
    );

    decoder3to8 U3 (
        .sel(count[2:0]),
        .out(leds)
    );
endmodule
