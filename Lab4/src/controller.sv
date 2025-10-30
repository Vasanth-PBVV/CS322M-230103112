module controller(
  input logic [6:0] op,
  input logic [2:0] funct3,
  input logic funct7b5,
  input logic Zero,         // From ALU zero flag for branch decisions

  output logic [1:0] ResultSrc,    // Select write-back source: 00=ALU, 01=Mem, 10=PC+4
  output logic MemWrite,
  output logic PCSrc,        // PC source: 0=PC+4, 1=branch/jump target
  output logic ALUSrc,       // ALU source: 0=reg2, 1=imm
  output logic RegWrite,
  output logic Jump,
  output logic [1:0] ImmSrc,     // Immediate type select
  output logic [2:0] ALUControl  // ALU operation
);

  // Opcode definitions
  localparam [6:0]
    OP_LUI    = 7'b0110111,
    OP_AUIPC  = 7'b0010111,
    OP_JAL    = 7'b1101111,
    OP_JALR   = 7'b1100111,
    OP_BRANCH = 7'b1100011,
    OP_LOAD   = 7'b0000011,
    OP_STORE  = 7'b0100011,
    OP_OP_IMM = 7'b0010011,
    OP_OP     = 7'b0110011;

  // Immediate type encoding
  localparam [1:0]
    IMM_I = 2'b00,
    IMM_S = 2'b01,
    IMM_B = 2'b10,
    IMM_U = 2'b11;

  // ALU operations encoding
  localparam [2:0]
    ALU_ADD  = 3'b000,
    ALU_SUB  = 3'b001,
    ALU_AND  = 3'b010,
    ALU_OR   = 3'b011,
    ALU_XOR  = 3'b100,
    ALU_SLT  = 3'b101,
    ALU_SLTU = 3'b110,
    ALU_NOP  = 3'b111;

  // Custom ALU ops codes for RVX10 extension (example)
  // These can be added to ALU controller logic elsewhere as needed

  always_comb begin
    // Default outputs
    ResultSrc = 2'b00;
    MemWrite = 0;
    PCSrc = 0;
    ALUSrc = 0;
    RegWrite = 0;
    Jump = 0;
    ImmSrc = IMM_I;
    ALUControl = ALU_ADD;

    case (op)
      OP_LUI: begin
        RegWrite = 1;
        ResultSrc = 2'b00; // ALU result
        ALUControl = ALU_NOP; // Logic handled elsewhere for LUI
        ImmSrc = IMM_U;
        ALUSrc = 1; // Use immediate
      end

      OP_AUIPC: begin
        RegWrite = 1;
        ResultSrc = 2'b00; // ALU
        ALUControl = ALU_ADD;
        ImmSrc = IMM_U;
        ALUSrc = 1;
      end

      OP_JAL: begin
        RegWrite = 1;
        ResultSrc = 2'b10; // PC+4
        PCSrc = 1;
        Jump = 1;
        ImmSrc = IMM_B;
      end

      OP_JALR: begin
        RegWrite = 1;
        ResultSrc = 2'b10; // PC+4
        PCSrc = 1;
        Jump = 1;
        ImmSrc = IMM_I;
        ALUSrc = 1;
      end

      OP_BRANCH: begin
        PCSrc = 0; // Default PC + 4, changed below for taken branches
        Jump = 0;
        ImmSrc = IMM_B;
        case (funct3)
          3'b000: PCSrc = Zero;       // BEQ
          3'b001: PCSrc = ~Zero;      // BNE
          3'b100: PCSrc = (ALUControl == ALU_SLT) ? 1 : 0;   // BLT
          3'b101: PCSrc = (ALUControl != ALU_SLT) ? 1 : 0;   // BGE
          3'b110: PCSrc = (ALUControl == ALU_SLTU) ? 1 : 0;  // BLTU
          3'b111: PCSrc = (ALUControl != ALU_SLTU) ? 1 : 0;  // BGEU
          default: PCSrc = 0;
        endcase
      end

      OP_LOAD: begin
        RegWrite = 1;
        ResultSrc = 2'b01;  // Data Memory
        MemWrite = 0;
        ALUSrc = 1;
        ImmSrc = IMM_I;
        ALUControl = ALU_ADD; // Address calculation
      end

      OP_STORE: begin
        MemWrite = 1;
        RegWrite = 0;
        ALUSrc = 1;
        ImmSrc = IMM_S;
        ALUControl = ALU_ADD;
        ResultSrc = 2'b00; // Don't care
      end

      OP_OP_IMM: begin
        RegWrite = 1;
        ALUSrc = 1;
        ImmSrc = IMM_I;
        case (funct3)
          3'b000: ALUControl = ALU_ADD; // ADDI
          3'b111: ALUControl = ALU_AND; // ANDI
          3'b110: ALUControl = ALU_OR;  // ORI
          3'b100: ALUControl = ALU_XOR; // XORI
          3'b010: ALUControl = ALU_SLT; // SLTI
          3'b011: ALUControl = ALU_SLTU; // SLTIU
          default: ALUControl = ALU_NOP;
        endcase
      end

      OP_OP: begin
        RegWrite = 1;
        ALUSrc = 0;
        ImmSrc = IMM_I;
        case ({funct7b5, funct3})
          4'b0000: ALUControl = ALU_ADD; // ADD
          4'b1000: ALUControl = ALU_SUB; // SUB
          4'b1110: ALUControl = ALU_AND; // AND
          4'b1100: ALUControl = ALU_OR;  // OR
          4'b1001: ALUControl = ALU_XOR; // XOR
          4'b0100: ALUControl = ALU_SLT; // SLT
          4'b0110: ALUControl = ALU_SLTU; // SLTU
          default: ALUControl = ALU_NOP;
        endcase
      end

      default: begin
        ResultSrc = 2'b00;
        MemWrite = 0;
        PCSrc = 0;
        ALUSrc = 0;
        RegWrite = 0;
        Jump = 0;
        ImmSrc = IMM_I;
        ALUControl = ALU_NOP;
      end

    endcase
  end

endmodule
