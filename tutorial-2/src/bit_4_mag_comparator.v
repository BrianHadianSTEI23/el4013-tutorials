module bit_4_mag_comparator
(
    input wire [3 : 0] A,
    input wire [3 : 0] B,
    output reg gt, lt, eq
);
    
    assign gt = (A > B) ? 1'b1 :
                (A == B) ? 1'b0 :
                (A < B) ? 1'b0;
    
    assign lt = (A > B) ? 1'b0 :
                (A == B) ? 1'b0 :
                (A < B) ? 1'b1;
    
    assign eq = (A == B);

endmodule