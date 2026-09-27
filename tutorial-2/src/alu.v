module alu (
    input  wire [2:0] op,
    input  wire [7:0] A,
    input  wire [7:0] B,
    output reg  [7:0] Y,
    output wire       zero,
    output wire       negative,
    output wire       overflow,
    output wire       carry
);
    reg [8:0] sum_ext;

    assign zero     = (Y == 8'h00);
    assign negative = Y[7];
    assign carry    = (op == 3'b000 || op == 3'b001) ? sum_ext[8] : 1'b0;
    
    // Signed overflow for ADD and SUB
    assign overflow = (op == 3'b000) ? (~(A[7] ^ B[7]) & (A[7] ^ Y[7])) :
                      (op == 3'b001) ? ((A[7] ^ B[7])  & (A[7] ^ Y[7])) : 1'b0;

    always @(*) begin
        sum_ext = 9'b0;
        case (op)
            3'b000: begin
                sum_ext = A + B;
                Y       = sum_ext[7:0];
            end
            3'b001: begin
                sum_ext = A - B;
                Y       = sum_ext[7:0];
            end
            3'b010: begin 
                Y       = A & B;
            end
            3'b011: begin 
                Y       = A | B;
            end
            3'b100: begin 
                Y       = A ^ B;
            end
            3'b101: begin 
                Y       = ($signed(A) < $signed(B)) ? 8'h01 : 8'h00;
            end
            default: begin
                Y       = 8'h00;
            end
        endcase
    end
endmodule