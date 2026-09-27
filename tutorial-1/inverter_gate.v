module inverter_gate
#(parameter NInp = 32, NOut = 32)
(
    input wire [NInp - 1:0] a,
    output wire [NOut - 1:0] b
);
    
    assign b = ~a;
endmodule