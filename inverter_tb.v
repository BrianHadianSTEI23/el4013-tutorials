`include "inverter_gate.v"

module inverter_tb();

    parameter NInp = 32,
              NOut = 32;

    // Inputs
    reg [NInp - 1 : 0] a;
    
    // outputs
    wire [NOut - 1 : 0] b;

    inverter_gate #(.NInp(NInp), .NOut(NOut)) G1
    (
        .a(a),
        .b(b)
    );

    initial begin
        $dumpfile("inverter_tb.vcd");
        $dumpvars(0, inverter_tb);

        a = 0;
        #10;
        a = 1;
        #10;

    end

endmodule