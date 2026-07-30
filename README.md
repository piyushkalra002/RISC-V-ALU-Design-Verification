# RISC-V ALU Design & Verification

A parameterized 32-bit ALU implementing the core arithmetic, logical, and comparison
operations from the RV32I instruction set, built in Verilog and verified with a
self-checking SystemVerilog testbench.

## Operations Supported
ADD, SUB, AND, OR, XOR, SLT (signed less-than comparison)

## Design
- Fully parameterized (`WIDTH` parameter), not hardcoded to 32 bits, can be
  instantiated at any bit width
- Dedicated `overflow` output with real signed-overflow detection logic for
  ADD and SUB (both operands share a sign, but the result flips sign)

## Verification Approach
- **Directed tests** — one targeted case per operation, including a signed
  comparison edge case (negative vs. positive operand) and an explicit
  overflow case (`0x7FFFFFFF + 1`)
- **Self-checking** — every test automatically compares actual output against
  an expected value and reports PASS/FAIL, rather than requiring manual
  inspection of printed results
- **Randomized testing** — 200 randomly generated input combinations, each
  checked against an independent reference model (a separate function that
  recomputes the correct answer from scratch, not the ALU's own logic) —
  this is what makes the randomized pass meaningful rather than circular

## Results
**207 / 207 tests passing** (6 directed + 1 overflow case + 200 randomized), 0 failures.

## Files
- `alu.v` the parameterized ALU design
- `alu_tb.sv` the self-checking testbench with reference model and randomized testing

## Run It Yourself
Live, runnable version on EDA Playground: [add your share link here]

## Tools
Verilog, SystemVerilog, Icarus Verilog (simulation)
