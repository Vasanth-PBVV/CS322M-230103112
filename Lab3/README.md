RVX10 Custom Instructions Assignment

Files:
- src/riscvsingle.sv: Single-cycle RISC-V core with RVX10 decode and ALU
- docs/ENCODINGS.md: Bitfield details and instruction encodings
- docs/TESTPLAN.md: Test plan with inputs and expected outputs
- tests/rvx10.hex: Hex memory initialization for testbench
- README.md: This document

Build & Run:
- Use your Verilog simulator to compile src/riscvsingle.sv
- Load tests/rvx10.hex as instruction memory image
- Run simulation for all instructions to execute
- Verify output matches expected results in TESTPLAN.md
- Test harness detects success by memory address 100 = 25

Notes:
- Writes to x0 are discarded by hardware.
- Rotates by zero result in original rs1 value.
- ABS handles INT_MIN as is without overflow traps.
- ALU is purely combinational; all RVX10 ops are single cycle.
