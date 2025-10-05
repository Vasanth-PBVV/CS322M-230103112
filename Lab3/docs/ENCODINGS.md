RVX10 Instruction Set Encodings

All RVX10 instructions have R-type format with:
Opcode: 0x0B (binary 0001011)
Fields: funct7, rs2, rs1, funct3, rd, opcode

Instruction encoding (32 bits):
| funct7 (7 bits) | rs2 (5 bits) | rs1 (5 bits) | funct3 (3 bits) | rd (5 bits) | opcode (7 bits) |
|-----------------|--------------|--------------|-----------------|-------------|-----------------|

Instruction details:

| Name | Opcode | funct7  | funct3 | rs2 usage     | Semantics                         |
|------|--------|---------|--------|--------------|----------------------------------|
| ANDN | 0x0B   | 0000000 | 000    | rs2          | rd = rs1 & ~rs2                  |
| ORN  | 0x0B   | 0000000 | 001    | rs2          | rd = rs1 | ~rs2                  |
| XNOR | 0x0B   | 0000000 | 010    | rs2          | rd = ~(rs1 ^ rs2)                |
| MIN  | 0x0B   | 0000001 | 000    | rs2          | rd = (int32(rs1) < int32(rs2))?rs1:rs2 |
| MAX  | 0x0B   | 0000001 | 001    | rs2          | rd = (int32(rs1) > int32(rs2))?rs1:rs2 |
| MINU | 0x0B   | 0000001 | 010    | rs2          | rd = (rs1 < rs2)? rs1 : rs2     |
| MAXU | 0x0B   | 0000001 | 011    | rs2          | rd = (rs1 > rs2)? rs1 : rs2     |
| ROL  | 0x0B   | 0000010 | 000    | rs2[4:0]     | rd = (rs1 << s) | (rs1 >> (32 - s)) s=rs2[4:0]|
| ROR  | 0x0B   | 0000010 | 001    | rs2[4:0]     | rd = (rs1 >> s) | (rs1 << (32 - s)) s=rs2[4:0]|
| ABS  | 0x0B   | 0000011 | 000    | ignored(rs2=0)| rd = (int32(rs1)>=0)?rs1:-rs1   |

Example encoding for ANDN x5,x6,x7:
funct7=0b0000000 (0x00 << 25)
rs2 = x7=7 (7<<20)
rs1 = x6=6 (6<<15)
funct3 = 0b000 (0<<12)
rd = x5=5 (5<<7)
opcode = 0x0B
Encoding = 0x00_007_006_000_005_0B = 0x00E... (Compute exact hex)

---

Other instructions similarly encoded by assembling bitfields.

Note: Writes to x0 are ignored by HW.
