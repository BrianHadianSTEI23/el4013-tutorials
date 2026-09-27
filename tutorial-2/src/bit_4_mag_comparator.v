module bit_4_mag_comparator
(
    input wire [3 : 0] A,
    input wire [3 : 0] B,
    output wire gt, lt, eq
);
    
    assign gt = (A > B);
    assign lt = (A < B);
    assign eq = (A == B);

endmodule