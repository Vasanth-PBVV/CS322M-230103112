RVX10 Test Plan

Test inputs and expected outputs per instruction:

1. ANDN: rs1=0xF0F0A5A5, rs2=0x0F0FFFFF  
   Expected rd = rs1 & ~rs2 = 0xF0F00000

2. ORN: rs1=0x12345678, rs2=0x00FF00FF  
   Expected rd = rs1 | ~rs2

3. XNOR: rs1=0xAAAAAAAA, rs2=0x55555555  
   Expected rd = ~(rs1 ^ rs2) = 0xFFFFFFFF

4. MIN: rs1=10, rs2=20  
   Expected rd = 10

5. MAX: rs1=20, rs2=10  
   Expected rd = 20

6. MINU: rs1=0xFFFF_FFFE, rs2=0x00000001  
   Expected rd = 0x00000001

7. MAXU: rs1=0x00000001, rs2=0xFFFFFFFE  
   Expected rd = 0xFFFFFFFE

8. ROL: rs1=0x80000001, rs2=3  
   Expected rd = rotate left by 3

9. ROR: rs1=0x80000001, rs2=1  
   Expected rd = rotate right by 1

10. ABS: rs1=0xFFFFFF80 (-128), rs2 = 0  
    Expected rd = 128

Checks:
- After all ops, store 25 to memory address 100 for test harness success.
- Optionally store checksum or diagnostic values in nearby memory.

Use $readmemh to load test input hex file and simulate execution.
