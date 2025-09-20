module detector (
    input wire [3:0] data_in,
    output wire match
);

    assign match = (data_in == 4'b0101); // ID = 5

endmodule
