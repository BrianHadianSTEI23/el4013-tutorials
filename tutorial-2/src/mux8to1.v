module mux8to1
(
    input wire [7 : 0] d,
    input wire [2 : 0] sel,
    input wire en_n,
    output reg q
);
    
    always @(*) begin
        if (en_n) begin
            q = 1'b0; 
        end else begin
            case (sel)
                3'b000:  q = d[0];
                3'b001:  q = d[1];
                3'b010:  q = d[2]; 
                3'b011:  q = d[3];
                3'b100:  q = d[4];
                3'b101:  q = d[5];
                3'b110:  q = d[6];
                3'b111:  q = d[7];
                default: q = 1'b0;
            endcase
        end
    end
endmodule