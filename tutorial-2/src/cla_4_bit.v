module cla_4_bit
(
    input wire [3 : 0] a,
    input wire [3 : 0] b,
    output wire [3 : 0] q
);
    wire [3 : 0] p;       
    wire [3 : 0] g;       
    wire [3 : 0] c;       

    p[0] = a[0] xor b[0];
    p[1] = a[1] xor b[1];
    p[2] = a[2] xor b[2];
    p[3] = a[3] xor b[3];

    g[0] = a[0] and b[0];
    g[1] = a[1] and b[1];
    g[2] = a[2] and b[2];
    g[3] = a[3] and b[3];

    c[0] = 1'b0;
    c[1] = g[0] xor p[0] and c[0];
    c[2] = g[1] xor p[1] and c[1];
    c[3] = g[2] xor p[2] and c[2];

    q[0] = p[0];
    q[1] = p[1] xor c[1]; 
    q[2] = p[2] xor c[2];
    q[3] = p[3] xor c[3];

endmodule