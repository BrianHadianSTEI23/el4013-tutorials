`timescale 1ns/1ps

module tb_mux8to1;
    reg  [7:0] d;
    reg  [2:0] sel;
    reg        en_n;
    wire       q;

    mux8to1 uut (
        .d(d), .sel(sel), .en_n(en_n), .q(q)
    );

    integer i;

    initial begin
        $dumpfile("wave_mux.vcd");
        $dumpvars(0, tb_mux8to1);

        d = 8'b1010_0110;
        
        en_n = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0]; #10;
        end

        en_n = 1'b0;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0]; #10;
        end

        $finish;
    end
endmodule