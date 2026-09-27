`timescale 1ns / 1ps

module tb_priority_encoder;

    parameter INPUT_WIDTH = 8;
    parameter OUTPUT_WIDTH = $clog2(INPUT_WIDTH);

    reg  [INPUT_WIDTH-1:0]  tb_in;
    wire [OUTPUT_WIDTH-1:0] tb_out;
    wire tb_valid;

    priority_encoder #(
        .INPUT_WIDTH(INPUT_WIDTH)
    ) uut (
        .in(tb_in),
        .out(tb_out),
        .valid(tb_valid)
    );

    initial begin
        $display("Time\t Input (Bin)\t Valid\t Encoded Output (Dec)");
        $monitor("%0t\t %b\t %b\t %d", $time, tb_in, tb_valid, tb_out);

        tb_in = 8'b0000_0000; #10;

        tb_in = 8'b0000_0100; #10;

        tb_in = 8'b0100_1001; #10;

        tb_in = 8'b1000_0000; #10;

        tb_in = 8'b1111_1111; #10;

        $finish;
    end

endmodule