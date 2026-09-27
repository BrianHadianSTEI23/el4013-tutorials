`timescale 1ns/1ps

module tb_cla_4_bit;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    cla_4_bit uut (
        .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout)
    );

    initial begin
        $dumpfile("wave_cla.vcd");
        $dumpvars(0, tb_cla_4_bit);

        cin = 1'b0;
        a = 4'd3;  b = 4'd2;  #10; // Sum = 5, Cout = 0
        a = 4'd8;  b = 4'd7;  #10; // Sum = 15, Cout = 0
        a = 4'd10; b = 4'd6;  #10; // Overflow case: Sum = 0, Cout = 1
        a = 4'd15; b = 4'd15; #10; // Boundary max: Sum = 14, Cout = 1

        cin = 1'b1;
        a = 4'd5;  b = 4'd4;  #10; // Sum = 10, Cout = 0

        $finish;
    end
endmodule