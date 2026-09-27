
module priority_encoder #(
    parameter INPUT_WIDTH  = 8,                        
    parameter OUTPUT_WIDTH = $clog2(INPUT_WIDTH)       
)(
    input  wire [INPUT_WIDTH-1:0]  in,                 
    output reg [OUTPUT_WIDTH-1:0] out,                
    output wire valid               
);

    integer i;

    assign valid = |in;

    always @(*) begin
        out = {OUTPUT_WIDTH{1'b0}};

        for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
            if (in[i]) begin
                out = i[OUTPUT_WIDTH-1:0];
            end
        end
    end

endmodule