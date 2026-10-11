#!/usr/bin/env python3
"""
Golden Model for 2D Sequential Convolution Engine
Computes reference Y[3x3] from PDF-specified matrices.
"""

# PDF Section 5: Exact test matrices
X = [
    [2, 2, 0, 1, 3],
    [1, 1, 3, 2, 0],
    [2, 1, 2, 1, 1],
    [0, 3, 0, 2, 2],
    [1, 0, 1, 0, 2]
]

K = [
    [1, 0, -1],
    [1, 0, -1],
    [1, 0, -1]
]

def conv2d_5x5_3x3(X, K):
    """Compute 2D convolution: Y[i,j] = sum_m sum_n X[i+m, j+n] * K[m,n]"""
    Y = [[0 for _ in range(3)] for _ in range(3)]
    
    for i in range(3):
        for j in range(3):
            acc = 0
            for m in range(3):
                for n in range(3):
                    acc += X[i + m][j + n] * K[m][n]
            Y[i][j] = acc
    return Y

def to_signed_20bit(val):
    """Convert to 20-bit signed representation"""
    if val < 0:
        val = (1 << 20) + val
    return val & 0xFFFFF

def main():
    print("=" * 60)
    print("Golden Model: 5x5 Input * 3x3 Kernel -> 3x3 Output")
    print("=" * 60)
    
    print("\nInput Matrix X (5x5, unsigned 8-bit):")
    for row in X:
        print("  " + " ".join(f"{v:3d}" for v in row))
    
    print("\nKernel Matrix K (3x3, signed 8-bit):")
    for row in K:
        print("  " + " ".join(f"{v:3d}" for v in row))
    
    Y = conv2d_5x5_3x3(X, K)
    
    print("\nOutput Matrix Y (3x3, signed 20-bit):")
    print("  Decimal                    Hex (20-bit)")
    print("  " + "-" * 45)
    for i in range(3):
        row_dec = " ".join(f"{Y[i][j]:6d}" for j in range(3))
        row_hex = " ".join(f"0x{to_signed_20bit(Y[i][j]):05X}" for j in range(3))
        print(f"  {row_dec}    {row_hex}")
    
    print("\n" + "=" * 60)
    print("Reference values for testbench assertions:")
    print("=" * 60)
    for i in range(3):
        for j in range(3):
            val = Y[i][j]
            hex_val = to_signed_20bit(val)
            print(f"  Y[{i}][{j}] = {val:6d}  (0x{hex_val:05X})")

if __name__ == "__main__":
    main()