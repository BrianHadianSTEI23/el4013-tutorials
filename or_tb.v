`include "or_gate.v"

module or_tb();

    parameter NInp = 32,
              NOut = 32;

    // Inputs
    reg [NInp - 1 : 0] a;
    reg [NInp - 1 : 0] b;
    
    // outputs
    wire [NOut - 1 : 0] c;

    or_gate #(.NInp(NInp), .NOut(NOut)) G1
    (
        .a(a),
        .b(b),
        .c(c)
    );

    initial begin
        $dumpfile("or_tb.vcd");
        $dumpvars(0, or_tb);

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