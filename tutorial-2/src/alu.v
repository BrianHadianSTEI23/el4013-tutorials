module alu
(
    input wire [3 : 0] op,
    input wire [3 : 0] A,
    input wire [3 : 0] B,

    output wire zero, 
    output wire negative, 
    output wire overflow, 
    output wire carry, 
);
    wire q [4 : 0];

    zero = 1'b0;
    negative = 1'b0;
    overflow = 1'b0;
    carry = 1'b0;

    always @(*) begin
        case (op)
            3'b000   : begin
                q = A + B; 
                if (q > 16) begin
                    overflow = 1'b1;
                    carry = 1'b1;
                end 
                else if (q == 0) begin
                    zero = 1'b1;
                end
            end 
            3'b001   : begin
                q = A - B; 
                if (q < 0) begin
                    overflow = 1'b1;
                    negative = 1'b1;
                end 
                else if (q == 0) begin
                    zero = 1'b1;
                end
            end
            3'b010   : begin
                q = A and B; 
                if (q == 0) begin
                    zero = 1'b1;
                end
            end
            3'b011   : begin
                q = A or B; 
                if (q == 0) begin
                    zero = 1'b1;
                end
            end
            3'b100   : begin
                q = A xor B; 
                if (q == 0) begin
                    zero = 1'b1;
                end
            end
            default  : begin
                q = 3'b000;
                if (q == 0) begin
                    zero = 1'b1;
                end
            end
        endcase
    end

endmodule