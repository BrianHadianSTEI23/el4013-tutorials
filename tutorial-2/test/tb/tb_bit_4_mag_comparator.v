`timescale 1ns/1ps

module tb_bit_4_mag_comparator;
    reg  [3:0] A, B;
    wire       gt, lt, eq;

    bit_4_mag_comparator uut (
        .A(A), .B(B), .gt(gt), .lt(lt), .eq(eq)
    );

    initial begin
        $dumpfile("wave_comparator.vcd");
        $dumpvars(0, tb_bit_4_mag_comparator);

        A = 4'd0;  B = 4'd0;  #10; // A == B 
        A = 4'd15; B = 4'd0;  #10; // A > B  
        A = 4'd0;  B = 4'd15; #10; // A < B
        A = 4'd7;  B = 4'd3;  #10; // A > B
        A = 4'd4;  B = 4'd9;  #10; // A < B
        A = 4'd12; B = 4'd12; #10; // A == B

        $finish;
    end
endmodule