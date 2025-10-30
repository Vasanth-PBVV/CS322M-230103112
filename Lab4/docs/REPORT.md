# RVX10-P Pipelined RISC-V Processor Implementation Report

## Introduction
This project implements a five-stage pipelined RISC-V processor called RVX10-P as an extension of a single-cycle RV32I CPU design. The RVX10-P supports all base RV32I instructions and 10 custom ALU instructions under the RVX10 extension.

## Design Overview
The processor pipeline follows the conventional five stages:
- Instruction Fetch (IF)
- Instruction Decode and Register Read (ID)
- Execute and Branch Decision (EX)
- Memory Access (MEM)
- Write Back (WB)

Pipeline registers separate stages, holding necessary control and data signals. The design includes hazard detection and forwarding units to handle data hazards by stalling or forwarding operands between pipeline stages.

## Modules Implemented
- **riscvpipeline.sv**: Top-level pipelined CPU integrating datapath, control, hazard detection, forwarding.
- **controller.sv**: Generates control signals based on opcode, funct3, and funct7 fields.
- **datapath.sv**: Implements ALU operations, register file, pipeline registers, and data memory access.
- **hazard_detection_unit.sv**: Detects load-use hazards; stalls pipeline accordingly.
- **forwarding_unit.sv**: Resolves data hazards by forwarding ALU inputs from EX/MEM or MEM/WB pipeline registers.

## Testbench and Verification
A self-checking testbench (tb_pipeline.sv) drives the processor, generating clock and reset signals, loading test programs, and monitoring memory outputs. Waveform dumping enables detailed signal inspection via GTKWave.

The project was successfully simulated using Icarus Verilog. The test program verifies functional correctness by checking the expected value stored in memory, confirming accurate pipelined execution with hazard management.

## Conclusion
The RVX10-P provides improved throughput over the single-cycle processor by overlapping instruction execution across pipeline stages while maintaining architectural correctness. This project reinforces understanding of pipelined processor design, hazard handling, and system-level verification with waveform analysis.

## References
- Assignment documents and lecture materials from CS322M.
- "Digital Design and Computer Architecture", Harris & Harris.
- Open-source RISC-V resources and educational CPU examples.

