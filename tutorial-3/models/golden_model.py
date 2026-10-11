#!/usr/bin/env python3
"""
Sequential 2D Convolution Engine Golden Model & Verification Script
Course: VLSI System - STEI ITB
Target: 5x5 Input Image (X), 3x3 Filter Kernel (K) -> 3x3 Output Matrix (Y)
"""

import numpy as np


def to_hex_20bit(val: int) -> str:
    """Converts a signed integer to a 20-bit 2's complement hexadecimal string."""
    mask_20bit = 0xFFFFF
    val_unsigned = val & mask_20bit
    return f"0x{val_unsigned:05X}"


def run_golden_model():
    # 1. Input Specification Data Setup
    # Input X: 5x5 matrix of Unsigned 8-bit integers
    X = np.array(
        [
            [1, 2, 0, 1, 3],
            [2, 1, 3, 2, 0],
            [0, 1, 2, 1, 1],
            [1, 3, 0, 2, 2],
            [2, 0, 1, 0, 1],
        ],
        dtype=np.uint8,
    )

    # Kernel K: 3x3 matrix of Signed 8-bit integers (2's complement)
    K = np.array([[1, 0, -1], [1, 0, -1], [1, 0, -1]], dtype=np.int8)

    # Output Y: 3x3 matrix initialized to Signed 20-bit zero
    Y = np.zeros((3, 3), dtype=np.int32)

    print("=" * 65)
    print("      SEQUENTIAL 2D CONVOLUTION ENGINE - GOLDEN MODEL")
    print("=" * 65)

    print("\n--- Input Matrix X (5x5, Unsigned 8-bit) ---")
    print(X)

    print("\n--- Filter Kernel K (3x3, Signed 8-bit) ---")
    print(K)

    # 2. Golden Model 2D Convolution Calculation
    # Formula: Y[i,j] = sum_{m=0}^2 sum_{n=0}^2 X[i+m, j+n] * K[m,n]
    print("\n--- Element-wise Calculation Breakdown ---")
    for i in range(3):
        for j in range(3):
            acc = 0
            details = []
            for m in range(3):
                for n in range(3):
                    x_val = int(X[i + m, j + n])
                    k_val = int(K[m, n])
                    prod = x_val * k_val
                    acc += prod
                    details.append(f"({x_val}*{k_val})")
            Y[i, j] = acc
            print(
                f"Y[{i},{j}] = {' + '.join(details)} = {acc:3d} | Hex(20b): {to_hex_20bit(acc)}"
            )

    print("\n--- Output Matrix Y (3x3, Signed 20-bit Decimal) ---")
    print(Y)

    print("\n--- Output Matrix Y (3x3, Signed 20-bit Hexadecimal) ---")
    for row in Y:
        print("  ".join([to_hex_20bit(val) for val in row]))

    # 3. Hardware Clock Cycle & Timing Analysis
    print("\n" + "=" * 65)
    print("               HARDWARE TIMING & LATENCY ANALYSIS")
    print("=" * 65)

    cycles_load_x = 25  # 25 cycles for 5x5 unsigned bytes
    cycles_load_k = 9  # 9 cycles for 3x3 signed bytes
    # Concurrent load assumes data_X and data_K fed together on in_valid
    cycles_load_total = max(cycles_load_x, cycles_load_k)

    mac_per_pixel = 9  # 3x3 kernel MACs per output Y[i,j]
    total_pixels = 9  # 3x3 output matrix Y
    cycles_compute = total_pixels * mac_per_pixel  # 81 MAC cycles

    write_out_strobe_cycles = (
        9  # 1 pulse clock cycle per computed Y[i,j] element
    )
    fsm_state_transitions = 3  # IDLE -> LOAD -> COMPUTE -> DONE

    total_execution_cycles = (
        cycles_load_total + cycles_compute + fsm_state_transitions
    )

    print(f"1. Data Loading Phase (Concurrent) : {cycles_load_total} Clock Cycles")
    print(
        f"   - X Buffer (25 Bytes)           : {cycles_load_x} Cycles (Active during in_valid)"
    )
    print(
        f"   - K Buffer (9 Bytes)            : {cycles_load_k} Cycles (Active during in_valid)"
    )
    print(f"2. MAC Computation Phase           : {cycles_compute} Clock Cycles")
    print(f"   - Computed Pixels               : {total_pixels} elements")
    print(f"   - Sequential MACs/Pixel         : {mac_per_pixel} MAC operations")
    print(
        f"3. Output Strobe Assertions        : {write_out_strobe_cycles} Cycles (1 pulse per Y[i,j])"
    )
    print(
        f"4. State Transition Overhead       : {fsm_state_transitions} Cycles (IDLE/LOAD/DONE)"
    )
    print("-" * 65)
    print(
        f"TOTAL COMPUTATION LATENCY          : {total_execution_cycles} Clock Cycles"
    )
    print("=" * 65)

    return X, K, Y


if __name__ == "__main__":
    run_golden_model()