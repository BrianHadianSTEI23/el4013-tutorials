// ============================================================================
// Module Name  : conv2d_engine
// Description  : Sequential 2D Convolution Engine (5x5 Input X, 3x3 Kernel K)
// Target Specs : Input X (8-bit Unsigned), Kernel K (8-bit Signed 2's Comp),
//                Output Y (20-bit Signed), 1 Shared MAC Architecture.
// Course       : VLSI System - STEI ITB
// ============================================================================

`timescale 1ns / 1ps

module conv2d_engine (
    input  wire        clk,        // Main Clock Signal
    input  wire        rstn,       // Asynchronous Reset (Active Low)
    input  wire        start,      // Trigger signal to start convolution
    input  wire        in_valid,   // Input data valid indicator from buffer
    input  wire [7:0]  data_X,     // Sequential pixel data X[i,j] (Unsigned 8-bit)
    input  wire [7:0]  data_K,     // Sequential weight data K[m,n] (Signed 8-bit)
    output reg         out_valid,  // 1-clock pulse high when output Y[i,j] is valid
    output reg  [19:0] data_Y,     // Convolution result Y[i,j] (Signed 20-bit)
    output reg         done        // High when all 9 Y elements finish calculation
);

    // ========================================================================
    // FSM State Encoding
    // ========================================================================
    localparam [2:0] S_IDLE        = 3'd0,
                     S_LOAD        = 3'd1,
                     S_COMPUTE_MAC = 3'd2,
                     S_WRITE_OUT   = 3'd3,
                     S_DONE        = 3'd4;

    reg [2:0] current_state, next_state;

    // ========================================================================
    // Internal Buffer Registers
    // ========================================================================
    reg [7:0] X_buf [0:24]; // 25-Byte Register File for Input Matrix X (5x5)
    reg [7:0] K_buf [0:8];  // 9-Byte Register File for Kernel Matrix K (3x3)

    // ========================================================================
    // Indexers, Counters, and Loop Variables
    // ========================================================================
    reg [4:0] x_cnt;       // Input load counter for X (0 to 24)
    reg [3:0] k_cnt;       // Input load counter for K (0 to 8)
    reg [3:0] mac_cnt;     // MAC step counter per output pixel (0 to 8)
    reg [3:0] pixel_cnt;   // Computed output pixel counter (0 to 8)

    // Spatial Coordinate Counters
    reg [1:0] i_reg, j_reg; // Output matrix row (i) and column (j) indices [0..2]
    reg [1:0] m_reg, n_reg; // Kernel row (m) and column (n) indices [0..2]

    // Address Generation Signals
    wire [4:0] x_addr;
    wire [3:0] k_addr;

    // Address Calculation: X[5*(i+m) + (j+n)], K[3*m + n]
    assign x_addr = (i_reg + m_reg) * 5 + (j_reg + n_reg);
    assign k_addr = m_reg * 3 + n_reg;

    // ========================================================================
    // Datapath Components (Sequential Single MAC Architecture)
    // ========================================================================
    wire signed [8:0]  x_operand;  // Unsigned 8-bit zero-extended to signed 9-bit
    wire signed [7:0]  k_operand;  // Signed 8-bit kernel value
    wire signed [16:0] product;    // Signed 9x8 multiplication product
    reg  signed [19:0] acc_reg;    // 20-bit Signed Accumulator Register

    assign x_operand = {1'b0, X_buf[x_addr]};
    assign k_operand = $signed(K_buf[k_addr]);
    assign product   = x_operand * k_operand;

    // ========================================================================
    // FSM State Register & Synchronous Logic
    // ========================================================================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // ========================================================================
    // Next State Transition Logic (Combinational)
    // ========================================================================
    always @(*) begin
        case (current_state)
            S_IDLE: begin
                if (start)
                    next_state = S_LOAD;
                else
                    next_state = S_IDLE;
            end

            S_LOAD: begin
                if (in_valid && (x_cnt == 5'd24))
                    next_state = S_COMPUTE_MAC;
                else
                    next_state = S_LOAD;
            end

            S_COMPUTE_MAC: begin
                if (mac_cnt == 4'd8)
                    next_state = S_WRITE_OUT;
                else
                    next_state = S_COMPUTE_MAC;
            end

            S_WRITE_OUT: begin
                if (pixel_cnt == 4'd8)
                    next_state = S_DONE;
                else
                    next_state = S_COMPUTE_MAC;
            end

            S_DONE: begin
                if (!start)
                    next_state = S_IDLE;
                else
                    next_state = S_DONE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // ========================================================================
    // Datapath Register Updates & Control Logic (Sequential)
    // ========================================================================
    integer idx;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            x_cnt       <= 5'd0;
            k_cnt       <= 4'd0;
            mac_cnt     <= 4'd0;
            pixel_cnt   <= 4'd0;
            i_reg       <= 2'd0;
            j_reg       <= 2'd0;
            m_reg       <= 2'd0;
            n_reg       <= 2'd0;
            acc_reg     <= 20'sd0;
            out_valid   <= 1'b0;
            data_Y      <= 20'sd0;
            done        <= 1'b0;

            for (idx = 0; idx < 25; idx = idx + 1) X_buf[idx] <= 8'd0;
            for (idx = 0; idx < 9;  idx = idx + 1) K_buf[idx] <= 8'd0;
        end else begin
            case (current_state)
                S_IDLE: begin
                    x_cnt     <= 5'd0;
                    k_cnt     <= 4'd0;
                    mac_cnt   <= 4'd0;
                    pixel_cnt <= 4'd0;
                    i_reg     <= 2'd0;
                    j_reg     <= 2'd0;
                    m_reg     <= 2'd0;
                    n_reg     <= 2'd0;
                    acc_reg   <= 20'sd0;
                    out_valid <= 1'b0;
                    done      <= 1'b0;
                end

                S_LOAD: begin
                    if (in_valid) begin
                        if (x_cnt < 5'd25) begin
                            X_buf[x_cnt] <= data_X;
                            x_cnt        <= x_cnt + 1'b1;
                        end
                        if (k_cnt < 4'd9) begin
                            K_buf[k_cnt] <= data_K;
                            k_cnt        <= k_cnt + 1'b1;
                        end
                    end
                end

                S_COMPUTE_MAC: begin
                    out_valid <= 1'b0;

                    // Accumulate Multiplier Product
                    if (mac_cnt == 4'd0) begin
                        acc_reg <= $signed({{3{product[16]}}, product});
                    end else begin
                        acc_reg <= acc_reg + $signed({{3{product[16]}}, product});
                    end

                    // Increment Kernel Sub-space Indices (m, n)
                    if (n_reg == 2'd2) begin
                        n_reg <= 2'd0;
                        if (m_reg == 2'd2) begin
                            m_reg <= 2'd0;
                        end else begin
                            m_reg <= m_reg + 1'b1;
                        end
                    end else begin
                        n_reg <= n_reg + 1'b1;
                    end

                    mac_cnt <= mac_cnt + 1'b1;
                end

                S_WRITE_OUT: begin
                    // Strobe Output Signal for 1 Clock Cycle
                    out_valid <= 1'b1;
                    data_Y    <= acc_reg;

                    // Reset MAC Step Counter & Kernel Indices
                    mac_cnt <= 4'd0;
                    m_reg   <= 2'd0;
                    n_reg   <= 2'd0;

                    // Increment Pixel Counter & Update Output Indices (i, j)
                    pixel_cnt <= pixel_cnt + 1'b1;
                    if (j_reg == 2'd2) begin
                        j_reg <= 2'd0;
                        i_reg <= i_reg + 1'b1;
                    end else begin
                        j_reg <= j_reg + 1'b1;
                    end
                end

                S_DONE: begin
                    out_valid <= 1'b0;
                    done      <= 1'b1;
                end

                default: ;
            endcase
        end
    end

endmodule