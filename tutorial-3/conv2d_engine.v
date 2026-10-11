module conv2d_engine (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic        in_valid,
    input  logic [7:0]  data_X,
    input  logic [7:0]  data_K,
    output logic        out_valid,
    output logic [19:0] data_Y,
    output logic        done
);

    typedef enum logic [2:0] {
        IDLE         = 3'd0,
        LOAD         = 3'd1,
        COMPUTE_MAC  = 3'd2,
        WRITE_OUT    = 3'd3,
        DONE         = 3'd4
    } state_t;

    state_t current_state, next_state;

    logic [4:0] x_count;
    logic [3:0] k_count;
    logic [3:0] mac_cycle;
    logic [3:0] pixel_count;
    logic [1:0] i_reg, j_reg, m_reg, n_reg;

    logic [7:0] x_buffer [0:24];
    logic signed [7:0] k_buffer [0:8];

    logic signed [15:0] mult_result;
    logic signed [19:0] acc_reg;
    logic signed [19:0] acc_next;
    logic signed [19:0] adder_result;

    logic load_x_en, load_k_en;
    logic acc_clr, acc_ld;
    logic [4:0] x_addr;
    logic [3:0] k_addr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE:       if (start)                    next_state = LOAD;
            LOAD:       if (x_count == 5'd25 && k_count == 4'd9)  next_state = COMPUTE_MAC;
            COMPUTE_MAC: if (mac_cycle == 4'd9)      next_state = WRITE_OUT;
            WRITE_OUT:  if (pixel_count == 4'd9)      next_state = DONE;
                        else                          next_state = COMPUTE_MAC;
            DONE:       if (start)                    next_state = IDLE;
            default:    next_state = IDLE;
        endcase
    end

    always_comb begin
        load_x_en  = 1'b0;
        load_k_en  = 1'b0;
        acc_clr    = 1'b0;
        acc_ld     = 1'b0;
        out_valid  = 1'b0;
        done       = 1'b0;

        case (current_state)
            IDLE: begin
                acc_clr = 1'b1;
            end
            LOAD: begin
                if (in_valid) begin
                    if (x_count < 5'd25)
                        load_x_en = 1'b1;
                    else if (k_count < 4'd9)
                        load_k_en = 1'b1;
                end
            end
            COMPUTE_MAC: begin
                if (mac_cycle == 4'd0)
                    acc_clr = 1'b1;
                else
                    acc_ld = 1'b1;
            end
            WRITE_OUT: begin
                out_valid = 1'b1;
            end
            DONE: begin
                done = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_count <= 5'd0;
            k_count <= 4'd0;
        end else if (current_state == LOAD && in_valid) begin
            if (x_count < 5'd25)
                x_count <= x_count + 5'd1;
            else if (k_count < 4'd9)
                k_count <= k_count + 4'd1;
        end else if (current_state == IDLE) begin
            x_count <= 5'd0;
            k_count <= 4'd0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 25; i++) x_buffer[i] <= 8'd0;
            for (int i = 0; i < 9; i++)  k_buffer[i] <= 8'd0;
        end else begin
            if (load_x_en && in_valid)
                x_buffer[x_count] <= data_X;
            if (load_k_en && in_valid)
                k_buffer[k_count] <= data_K;
        end
    end

    always_comb begin
        x_addr = 5'd0;
        k_addr = 4'd0;
        if (current_state == COMPUTE_MAC || current_state == WRITE_OUT) begin
            x_addr = 5*(i_reg + m_reg) + (j_reg + n_reg);
            k_addr = 3*m_reg + n_reg;
        end
    end

    logic [7:0] x_mux_out;
    logic signed [7:0] k_mux_out;

    always_comb begin
        x_mux_out = x_buffer[x_addr];
        k_mux_out = k_buffer[k_addr];
    end

    assign mult_result = $signed({1'b0, x_mux_out}) * k_mux_out;
    assign adder_result = acc_reg + {{4{mult_result[15]}}, mult_result};

    always_comb begin
        if (acc_clr)
            acc_next = 20'sd0;
        else if (acc_ld)
            acc_next = adder_result;
        else
            acc_next = acc_reg;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            acc_reg <= 20'sd0;
        else
            acc_reg <= acc_next;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac_cycle   <= 4'd0;
            pixel_count <= 4'd0;
            i_reg       <= 2'd0;
            j_reg       <= 2'd0;
            m_reg       <= 2'd0;
            n_reg       <= 2'd0;
        end else begin
            case (current_state)
                COMPUTE_MAC: begin
                    if (mac_cycle == 4'd8) begin
                        mac_cycle <= 4'd0;
                        m_reg <= 2'd0;
                        n_reg <= 2'd0;
                    end else begin
                        mac_cycle <= mac_cycle + 4'd1;
                        if (n_reg == 2'd2) begin
                            m_reg <= m_reg + 2'd1;
                            n_reg <= 2'd0;
                        end else begin
                            n_reg <= n_reg + 2'd1;
                        end
                    end
                end
                WRITE_OUT: begin
                    if (pixel_count == 4'd8) begin
                        pixel_count <= 4'd0;
                        i_reg <= 2'd0;
                        j_reg <= 2'd0;
                    end else begin
                        pixel_count <= pixel_count + 4'd1;
                        if (j_reg == 2'd2) begin
                            i_reg <= i_reg + 2'd1;
                            j_reg <= 2'd0;
                        end else begin
                            j_reg <= j_reg + 2'd1;
                        end
                    end
                    m_reg <= 2'd0;
                    n_reg <= 2'd0;
                end
                IDLE: begin
                    mac_cycle   <= 4'd0;
                    pixel_count <= 4'd0;
                    i_reg       <= 2'd0;
                    j_reg       <= 2'd0;
                    m_reg       <= 2'd0;
                    n_reg       <= 2'd0;
                end
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_Y <= 20'd0;
        else if (current_state == WRITE_OUT)
            data_Y <= acc_reg;
    end

endmodule