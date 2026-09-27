`timescale 1ns/1ps

module tb_alu;
    reg  [2:0] op;
    reg  [7:0] A, B;
    wire [7:0] Y;
    wire       zero, negative, overflow, carry;

    alu uut (
        .op(op), .A(A), .B(B), .Y(Y),
        .zero(zero), .negative(negative), .overflow(overflow), .carry(carry)
    );

    integer i;

    initial begin
        $dumpfile("wave_alu.vcd");
        $dumpvars(0, tb_alu);

        // 1. ADD Test with Carry and Overflow
        op = 3'b000; A = 8'd200; B = 8'd100; #10; 
        op = 3'b000; A = 8'd120; B = 8'd10;  #10; 

        // 2. SUB Test with Zero and Negative flags
        op = 3'b001; A = 8'd50;  B = 8'd50;  #10; 
        op = 3'b001; A = 8'd10;  B = 8'd20;  #10; 

        // 3. Bitwise Logic
        op = 3'b010; A = 8'hFF; B = 8'h0F; #10; 
        op = 3'b011; A = 8'hF0; B = 8'h0F; #10; 
        op = 3'b100; A = 8'hAA; B = 8'hAA; #10;

        // 4. SLT Test
        op = 3'b101; A = 8'hFE; B = 8'h05; #10; 

        // 5. Randomized Testing (100+ Iterations)
        for (i = 0; i < 100; i = i + 1) begin
            op = $urandom_range(0, 5);
            A  = $urandom;
            B  = $urandom;
            #10;
        end

        $finish;
    end
endmodule