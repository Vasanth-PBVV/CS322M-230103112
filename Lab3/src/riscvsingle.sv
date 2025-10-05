// Single-cycle RISC-V core with RVX10 custom instructions extension
module riscvsingle(
  input logic clk, reset,
  input logic [31:0] instr,
  output logic [31:0] pc,
  output logic [31:0] mem_wdata,
  output logic [31:0] mem_addr,
  input  logic [31:0] mem_rdata,
  output logic mem_write
);

  logic [6:0] opcode = instr[6:0];
  logic [4:0] rd     = instr[11:7];
  logic [2:0] funct3 = instr[14:12];
  logic [4:0] rs1    = instr[19:15];
  logic [4:0] rs2    = instr[24:20];
  logic [6:0] funct7 = instr[31:25];

  // Register file
  logic [31:0] regfile [31:0];
  logic [31:0] rs1_val = (rs1 != 0) ? regfile[rs1] : 32'b0;
  logic [31:0] rs2_val = (rs2 != 0) ? regfile[rs2] : 32'b0;

  typedef enum logic [3:0] {
    ALU_NOP  = 4'd15,
    ALU_ANDN = 4'd0,
    ALU_ORN  = 4'd1,
    ALU_XNOR = 4'd2,
    ALU_MIN  = 4'd3,
    ALU_MAX  = 4'd4,
    ALU_MINU = 4'd5,
    ALU_MAXU = 4'd6,
    ALU_ROL  = 4'd7,
    ALU_ROR  = 4'd8,
    ALU_ABS  = 4'd9
  } alu_op_t;

  alu_op_t alu_op = ALU_NOP;

  // RVX10 decode
  always_comb begin
    if (opcode == 7'b0001011) begin
      unique case ({funct7,funct3})
        10'b0000000_000: alu_op = ALU_ANDN;
        10'b0000000_001: alu_op = ALU_ORN;
        10'b0000000_010: alu_op = ALU_XNOR;
        10'b0000001_000: alu_op = ALU_MIN;
        10'b0000001_001: alu_op = ALU_MAX;
        10'b0000001_010: alu_op = ALU_MINU;
        10'b0000001_011: alu_op = ALU_MAXU;
        10'b0000010_000: alu_op = ALU_ROL;
        10'b0000010_001: alu_op = ALU_ROR;
        10'b0000011_000: alu_op = ALU_ABS;
        default: alu_op = ALU_NOP;
      endcase
    end else begin
      alu_op = ALU_NOP;
    end
  end

  // ALU logic
  logic signed [31:0] s1 = rs1_val;
  logic signed [31:0] s2 = rs2_val;
  logic [31:0] alu_y;
  always_comb begin
    case (alu_op)
      ALU_ANDN: alu_y = rs1_val & ~rs2_val;
      ALU_ORN:  alu_y = rs1_val | ~rs2_val;
      ALU_XNOR: alu_y = ~(rs1_val ^ rs2_val);
      ALU_MIN:  alu_y = (s1 < s2) ? rs1_val : rs2_val;
      ALU_MAX:  alu_y = (s1 > s2) ? rs1_val : rs2_val;
      ALU_MINU: alu_y = (rs1_val < rs2_val) ? rs1_val : rs2_val;
      ALU_MAXU: alu_y = (rs1_val > rs2_val) ? rs1_val : rs2_val;
      ALU_ROL: begin
        logic [4:0] sh = rs2_val[4:0];
        alu_y = (sh == 0) ? rs1_val : ((rs1_val << sh) | (rs1_val >> (32 - sh)));
      end
      ALU_ROR: begin
        logic [4:0] sh = rs2_val[4:0];
        alu_y = (sh == 0) ? rs1_val : ((rs1_val >> sh) | (rs1_val << (32 - sh)));
      end
      ALU_ABS: alu_y = (s1 >= 0) ? rs1_val : (0 - rs1_val);
      default: alu_y = 32'b0;
    endcase
  end

  logic [31:0] next_pc = pc + 4;

  logic [31:0] wb_data = (opcode == 7'b0001011) ? alu_y : 32'b0;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc <= 0;
      // Reset regs optional
    end else begin
      pc <= next_pc;
      if ((rd != 0) && (opcode == 7'b0001011)) begin
        regfile[rd] <= wb_data;
      end
    end
  end

  assign mem_wdata = 32'b0;
  assign mem_addr = 32'b0;
  assign mem_write = 1'b0;

endmodule
