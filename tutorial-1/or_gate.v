module or_gate 
#(parameter NInp = 32, NOut = 32)
(
    input wire [NInp - 1:0] a,
    input wire [NInp - 1:0] b,
    output wire [NOut - 1:0] c
);
    
    assign c = a | b;
endmodule