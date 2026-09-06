`include "xor_gate.v"

module xor_tb();

    parameter NInp = 32,
              NOut = 32;

    // Inputs
    reg [NInp - 1 : 0] a;
    reg [NInp - 1 : 0] b;
    
    // outputs
    wire [NOut - 1 : 0] c;

    xor_gate #(.NInp(NInp), .NOut(NOut)) G1
    (
        .a(a),
        .b(b),
        .c(c)
    );

    initial begin
        $dumpfile("xor_tb.vcd");
        $dumpvars(0, xor_tb);

        a = 0;
        b = 0;
        #10;
        a = 0;
        b = 1;
        #10;
        a = 1;
        b = 0;
        #10;
        a = 1;
        b = 1;
        #10;
    end

endmodule