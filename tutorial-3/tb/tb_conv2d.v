// ============================================================================
// Module Name  : tb_conv2d
// Description  : Hardware Verification Testbench for 2D Sequential Conv Engine
// Course       : VLSI System - STEI ITB
// Target Unit  : conv2d_engine.v
// ============================================================================

`timescale 1ns / 1ps

module tb_conv2d;

    // ========================================================================
    // Clock and Reset Generation Configuration
    // ========================================================================
    reg clk;
    reg rstn;

    // Target Clock Frequency: 100 MHz (Period = 10ns)
    always #5 clk = ~clk;

    // ========================================================================
    // Interface Signals (DUT Connection)
    // ========================================================================
    reg        start;
    reg        in_valid;
    reg  [7:0] data_X;
    reg  [7:0] data_K;

    wire        out_valid;
    wire [19:0] data_Y;
    wire        done;

    // ========================================================================
    // Test Case Stimulus Memory Arrays
    // ========================================================================
    // Input X (5x5 Unsigned 8-bit Matrix)
    reg [7:0] test_X [0:24];

    // Kernel K (3x3 Signed 8-bit Matrix)
    reg [7:0] test_K [0:8];

    // Golden Reference Expected Y Results (3x3 Signed 20-bit Matrix)
    reg signed [19:0] golden_Y [0:8];

    // Captured Simulation Results
    reg signed [19:0] sim_Y [0:8];

    // Verification Counters & Indicators
    integer i, j, idx;
    integer rx_cnt;
    integer err_count;

    // ========================================================================
    // Design Under Test (DUT) Instantiation
    // ========================================================================
    conv2d_engine uut (
        .clk       (clk),
        .rstn      (rstn),
        .start     (start),
        .in_valid  (in_valid),
        .data_X    (data_X),
        .data_K    (data_K),
        .out_valid (out_valid),
        .data_Y    (data_Y),
        .done      (done)
    );

    // ========================================================================
    // Output Monitoring & Result Capture Block
    // ========================================================================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rx_cnt <= 0;
        end else if (out_valid) begin
            sim_Y[rx_cnt] <= $signed(data_Y);
            $display("[TIME %0t ns] Output Captured Y[%0d,%0d] = %d (Hex: 0x%05X)",
                     $time, rx_cnt/3, rx_cnt%3, $signed(data_Y), data_Y);
            rx_cnt <= rx_cnt + 1;
        end
    end

    // ========================================================================
    // Main Stimulus Sequence
    // ========================================================================
    initial begin
        // Setup Waveform Dumping
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_conv2d);

        // 1. Initialize Signal States
        clk      = 0;
        rstn     = 0;
        start    = 0;
        in_valid = 0;
        data_X   = 8'd0;
        data_K   = 8'd0;
        rx_cnt   = 0;
        err_count= 0;

        // 2. Load Stimulus Memory (Section 5 Spec)
        // Matrix X (5x5)
        test_X[0]=8'd1;  test_X[1]=8'd2;  test_X[2]=8'd0;  test_X[3]=8'd1;  test_X[4]=8'd3;
        test_X[5]=8'd2;  test_X[6]=8'd1;  test_X[7]=8'd3;  test_X[8]=8'd2;  test_X[9]=8'd0;
        test_X[10]=8'd0; test_X[11]=8'd1; test_X[12]=8'd2; test_X[13]=8'd1; test_X[14]=8'd1;
        test_X[15]=8'd1; test_X[16]=8'd3; test_X[17]=8'd0; test_X[18]=8'd2; test_X[19]=8'd2;
        test_X[20]=8'd2; test_X[21]=8'd0; test_X[22]=8'd1; test_X[23]=8'd0; test_X[24]=8'd1;

        // Matrix K (3x3 Signed)
        test_K[0]=8'sd1; test_K[1]=8'sd0; test_K[2]=-8'sd1;
        test_K[3]=8'sd1; test_K[4]=8'sd0; test_K[5]=-8'sd1;
        test_K[6]=8'sd1; test_K[7]=8'sd0; test_K[8]=-8'sd1;

        // Expected Golden Reference Matrix Y (3x3)
        golden_Y[0] = -20'sd2; golden_Y[1] =  20'sd0; golden_Y[2] =  20'sd1;
        golden_Y[3] = -20'sd2; golden_Y[4] =  20'sd0; golden_Y[5] =  20'sd2;
        golden_Y[6] =  20'sd0; golden_Y[7] =  20'sd1; golden_Y[8] = -20'sd1;

        // 3. Apply Hardware Reset
        #20;
        rstn = 1;
        #20;

        $display("=================================================");
        $display("   STARTING SEQUENTIAL CONVOLUTION SIMULATION   ");
        $display("=================================================");

        // 4. Assert Start Pulse
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        // 5. Feed Data sequentially during LOAD State
        @(posedge clk);
        in_valid = 1'b1;

        for (idx = 0; idx < 25; idx = idx + 1) begin
            data_X = test_X[idx];
            if (idx < 9) begin
                data_K = test_K[idx];
            end else begin
                data_K = 8'd0;
            end
            @(posedge clk);
        end

        in_valid = 1'b0;
        data_X   = 8'd0;
        data_K   = 8'd0;

        // 6. Wait for Hardware Computation to Signal Completion
        wait (done == 1'b1);
        @(posedge clk);

        $display("\n=================================================");
        $display("          VERIFICATION COMPARISON TABLE          ");
        $display("=================================================");
        $display(" Element | Expected (Golden) | Simulated (RTL) | Status ");
        $display("---------+-------------------+-----------------+--------");

        for (idx = 0; idx < 9; idx = idx + 1) begin
            if (sim_Y[idx] === golden_Y[idx]) begin
                $display(" Y[%0d,%0d]  | %17d | %15d | PASS  ",
                         idx/3, idx%3, golden_Y[idx], sim_Y[idx]);
            end else begin
                $display(" Y[%0d,%0d]  | %17d | %15d | FAIL  ",
                         idx/3, idx%3, golden_Y[idx], sim_Y[idx]);
                err_count = err_count + 1;
            end
        end

        $display("=================================================");
        if (err_count == 0) begin
            $display(" RESULT: ALL TEST CASES PASSED SUCCESSFULLY!    ");
        end else begin
            $display(" RESULT: SIMULATION FAILED WITH %0d ERRORS!     ", err_count);
        end
        $display("=================================================\n");

        #50;
        $finish;
    end

endmodule