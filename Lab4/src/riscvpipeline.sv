module riscvpipeline(input logic clk, reset);

  // Pipeline registers between stages
  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
  } ifid_reg_t;

  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] reg_data1;
    logic [31:0] reg_data2;
    logic [31:0] imm;
    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic funct7b5;
    logic mem_read;
    logic mem_write;
    logic alu_src;
    logic reg_write;
    logic [1:0] result_src;
    logic [1:0] imm_src;
    logic branch;
    logic jump;
    logic [2:0] alu_control;
  } idex_reg_t;

  typedef struct packed {
    logic [31:0] alu_result;
    logic [31:0] reg_data2;
    logic [4:0] rd;
    logic mem_read;
    logic mem_write;
    logic reg_write;
  } exmem_reg_t;

  typedef struct packed {
    logic [31:0] mem_read_data;
    logic [31:0] alu_result;
    logic [4:0] rd;
    logic reg_write;
  } memwb_reg_t;

  // Pipeline registers
  ifid_reg_t IFID;
  idex_reg_t IDEX;
  exmem_reg_t EXMEM;
  memwb_reg_t MEMWB;

  // PC register
  logic [31:0] pc, next_pc;

  // Instruction memory
  logic [31:0] instr;

  // Register file ports
  logic [31:0] reg_data1, reg_data2;

  // Immediate generation
  logic [31:0] imm_ext;

  // ALU wires
  logic [31:0] alu_src2, alu_result;
  logic alu_zero;

  // Data memory
  logic [31:0] mem_read_data;

  // Hazard detection & forwarding controls
  logic stall, flush;
  logic [1:0] forwardA, forwardB;

  // Forwarding muxes for ALU inputs
  logic [31:0] alu_in1, alu_in2;

  // PC update logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) pc <= 32'b0;
    else if (~stall) pc <= next_pc;
  end

  // Fetch stage: read instruction memory with pc
  imem imem_unit(.a(pc), .rd(instr));

  // Calculate next PC (default pc+4)
  logic [31:0] pc_plus4;
  assign pc_plus4 = pc + 4;

  // Branch target calculation for EX stage will be used later
  logic [31:0] branch_target;
  assign branch_target = IDEX.pc + IDEX.imm;

  // IF/ID Pipeline register update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      IFID <= '0;
    end else if (~stall) begin
      IFID.pc <= pc;
      IFID.instr <= instr;
    end
  end

  // Decode instruction fields
  wire [6:0] opcode = IFID.instr[6:0];
  wire [4:0] rs1 = IFID.instr[19:15];
  wire [4:0] rs2 = IFID.instr[24:20];
  wire [4:0] rd = IFID.instr[11:7];
  wire [2:0] funct3 = IFID.instr[14:12];
  wire funct7b5 = IFID.instr[30];

  // Register file
  regfile regfile_inst(
    .clk(clk), .we3(MEMWB.reg_write), 
    .a1(rs1), .a2(rs2), .a3(MEMWB.rd), 
    .wd3(MEMWB.reg_write ? MEMWB.mem_read_data : MEMWB.alu_result), 
    .rd1(reg_data1), .rd2(reg_data2)
  );

  // Immediate extension
  extend imm_ext_unit (
    .instr(IFID.instr[31:7]), .immsrc(IDEX.imm_src), .immext(imm_ext)
  );

  // Control Unit combinational signals (based on current instruction)
  logic [1:0] result_src;
  logic mem_write, reg_write, alu_src, branch, jump;
  logic [1:0] imm_src;
  logic [2:0] alu_control;

  controller ctrl(
    .op(opcode), .funct3(funct3), .funct7b5(funct7b5), .Zero(alu_zero), 
    .ResultSrc(result_src), .MemWrite(mem_write), .PCSrc(branch & alu_zero | jump),
    .ALUSrc(alu_src), .RegWrite(reg_write), .Jump(jump), .ImmSrc(imm_src),
    .ALUControl(alu_control)
  );

  // Hazard detection for stalls and flushes
  hazard_detection_unit hazard(
    .ID_rs1(rs1), .ID_rs2(rs2), .EX_rd(EXMEM.rd), .EX_mem_read(EXMEM.mem_read),
    .stall(stall), .flush(flush)
  );

  // Forwarding unit for data hazard resolution
  forwarding_unit fwd(
    .EX_rs1(IDEX.rs1), .EX_rs2(IDEX.rs2), .MEM_rd(EXMEM.rd), .MEM_reg_write(EXMEM.reg_write),
    .WB_rd(MEMWB.rd), .WB_reg_write(MEMWB.reg_write), .forwardA(forwardA), .forwardB(forwardB)
  );

  // ID/EX Pipeline register update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) IDEX <= '0;
    else if (~stall) begin
      IDEX.pc <= IFID.pc;
      IDEX.reg_data1 <= reg_data1;
      IDEX.reg_data2 <= reg_data2;
      IDEX.imm <= imm_ext;
      IDEX.rs1 <= rs1;
      IDEX.rs2 <= rs2;
      IDEX.rd <= rd;
      IDEX.opcode <= opcode;
      IDEX.funct3 <= funct3;
      IDEX.funct7b5 <= funct7b5;
      IDEX.mem_read <= (opcode == 7'b0000011);
      IDEX.mem_write <= mem_write;
      IDEX.alu_src <= alu_src;
      IDEX.reg_write <= reg_write;
      IDEX.result_src <= result_src;
      IDEX.imm_src <= imm_src;
      IDEX.branch <= branch;
      IDEX.jump <= jump;
      IDEX.alu_control <= alu_control;
    end
  end

  // Forwarding muxes for ALU inputs at EX stage
  always_comb begin
    case(forwardA)
      2'b00: alu_in1 = IDEX.reg_data1;
      2'b10: alu_in1 = EXMEM.alu_result;
      2'b01: alu_in1 = MEMWB.reg_write ? (MEMWB.mem_read_data) : MEMWB.alu_result;
      default: alu_in1 = IDEX.reg_data1;
    endcase
    case(forwardB)
      2'b00: alu_in2 = IDEX.alu_src ? IDEX.imm : IDEX.reg_data2;
      2'b10: alu_in2 = EXMEM.alu_result;
      2'b01: alu_in2 = MEMWB.reg_write ? (MEMWB.mem_read_data) : MEMWB.alu_result;
      default: alu_in2 = IDEX.alu_src ? IDEX.imm : IDEX.reg_data2;
    endcase
  end

  // EX stage ALU operation
  alu alu_inst(
    .a(alu_in1), .b(alu_in2), .alucontrol(IDEX.alu_control),
    .result(alu_result), .zero(alu_zero)
  );

  // EX/MEM pipeline register update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) EXMEM <= '0;
    else begin
      EXMEM.alu_result <= alu_result;
      EXMEM.reg_data2 <= IDEX.reg_data2;
      EXMEM.rd <= IDEX.rd;
      EXMEM.mem_read <= IDEX.mem_read;
      EXMEM.mem_write <= IDEX.mem_write;
      EXMEM.reg_write <= IDEX.reg_write;
    end
  end

  // MEM stage Data Memory access
  dmem dmem_unit(
    .clk(clk), .we(EXMEM.mem_write), .a(EXMEM.alu_result),
    .wd(EXMEM.reg_data2), .rd(mem_read_data)
  );

  // MEM/WB pipeline register update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) MEMWB <= '0;
    else begin
      MEMWB.mem_read_data <= mem_read_data;
      MEMWB.alu_result <= EXMEM.alu_result;
      MEMWB.rd <= EXMEM.rd;
      MEMWB.reg_write <= EXMEM.reg_write;
    end
  end

  // Writeback stage handled by regfile write enable (MEMWB.reg_write)

  // PC next logic with branch flush
  always_comb begin
    if (flush) begin
      next_pc = branch_target;
    end else begin
      next_pc = pc_plus4;
    end
  end

endmodule
