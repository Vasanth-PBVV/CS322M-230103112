module datapath(
  input logic clk, reset,
  input logic [31:0] pc_in,
  input logic pc_write,
  input logic ifid_write,
  input logic idex_flush,

  input logic [1:0] result_src,
  input logic mem_write,
  input logic alu_src,
  input logic reg_write,
  input logic [1:0] imm_src,
  input logic [2:0] alu_control,

  input logic branch,
  input logic jump,
  input logic [31:0] branch_target,

  output logic zero,
  output logic [31:0] alu_result,

  // Pipeline register outputs for hazard unit or forwarding unit
  output logic [4:0] idex_rs1, idex_rs2,
  output logic [4:0] exmem_rd,
  output logic exmem_mem_read,
  output logic memwb_reg_write,
  output logic [4:0] memwb_rd
);

  // PC register
  logic [31:0] pc;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) pc <= 0;
    else if (pc_write) pc <= pc_in;
  end

  // IF/ID pipeline register holding PC and instruction
  logic [31:0] ifid_pc, ifid_instr;
  always_ff @(posedge clk or posedge reset) begin
    if (reset || idex_flush) begin
      ifid_pc <= 0;
      ifid_instr <= 0;
    end else if (ifid_write) begin
      ifid_pc <= pc;
      ifid_instr <= /* fetched instruction from instruction memory */;
    end
  end

  // Extract fields from IF/ID instruction
  wire [6:0] opcode = ifid_instr[6:0];
  wire [4:0] rs1 = ifid_instr[19:15];
  wire [4:0] rs2 = ifid_instr[24:20];
  wire [4:0] rd = ifid_instr[11:7];
  wire [2:0] funct3 = ifid_instr[14:12];
  wire funct7b5 = ifid_instr[30];

  // Register file module declaration and ports
  logic [31:0] reg_data1, reg_data2;
  regfile regfile_inst(
    .clk(clk),
    .we3(memwb_reg_write),
    .a1(rs1),
    .a2(rs2),
    .a3(memwb_rd),
    .wd3(result_src == 2'b01 ? /* data memory read data */ : (result_src == 2'b10 ? pc + 4 : alu_result)),
    .rd1(reg_data1),
    .rd2(reg_data2)
  );

  // Immediate generation
  logic [31:0] imm_ext;
  extend imm_gen(
    .instr(ifid_instr),
    .imm_src(imm_src),
    .imm_out(imm_ext)
  );

  // ID/EX pipeline registers to hold decoded signals and operands
  logic [31:0] idex_pc, idex_reg_data1, idex_reg_data2, idex_imm;
  logic [4:0] idex_rs1_reg, idex_rs2_reg, idex_rd_reg;
  logic idex_mem_write, idex_reg_write;
  logic idex_alu_src;
  logic [2:0] idex_alu_control;
  logic [1:0] idex_result_src;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      idex_pc <= 0;
      idex_reg_data1 <= 0;
      idex_reg_data2 <= 0;
      idex_imm <= 0;
      idex_rs1_reg <= 0;
      idex_rs2_reg <= 0;
      idex_rd_reg <= 0;
      idex_mem_write <= 0;
      idex_reg_write <= 0;
      idex_alu_src <= 0;
      idex_alu_control <= 0;
      idex_result_src <= 0;
    end else begin
      idex_pc <= ifid_pc;
      idex_reg_data1 <= reg_data1;
      idex_reg_data2 <= reg_data2;
      idex_imm <= imm_ext;
      idex_rs1_reg <= rs1;
      idex_rs2_reg <= rs2;
      idex_rd_reg <= rd;
      idex_mem_write <= mem_write;
      idex_reg_write <= reg_write;
      idex_alu_src <= alu_src;
      idex_alu_control <= alu_control;
      idex_result_src <= result_src;
    end
  end

  // Forwarding multiplexers inputs selection for ALU operands will be implemented in forwarding unit module externally.

  // ALU second operand mux selection between register or immediate.
  logic [31:0] alu_operand2;
  assign alu_operand2 = idex_alu_src ? idex_imm : idex_reg_data2;

  // ALU instance declaration
  alu alu_inst (
    .a(idex_reg_data1),
    .b(alu_operand2),
    .alucontrol(idex_alu_control),
    .result(alu_result),
    .zero(zero)
  );

  // EX/MEM pipeline registers to hold ALU result, reg_data2, rd, control signals
  logic [31:0] exmem_alu_result, exmem_reg_data2;
  logic [4:0] exmem_rd_reg;
  logic exmem_mem_write, exmem_reg_write;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      exmem_alu_result <= 0;
      exmem_reg_data2 <= 0;
      exmem_rd_reg <= 0;
      exmem_mem_write <= 0;
      exmem_reg_write <= 0;
    end else begin
      exmem_alu_result <= alu_result;
      exmem_reg_data2 <= idex_reg_data2;
      exmem_rd_reg <= idex_rd_reg;
      exmem_mem_write <= idex_mem_write;
      exmem_reg_write <= idex_reg_write;
    end
  end

  // Data memory interface signals 
  logic [31:0] mem_read_data;

  data_memory dmem(
    .clk(clk),
    .we(exmem_mem_write),
    .a(exmem_alu_result),
    .wd(exmem_reg_data2),
    .rd(mem_read_data)
  );

  // MEM/WB pipeline registers to hold results and control signals for writeback stage
  logic [31:0] memwb_mem_read_data, memwb_alu_result;
  logic [4:0] memwb_rd_reg;
  logic memwb_reg_write_reg;
  logic [1:0] memwb_result_src;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      memwb_mem_read_data <= 0;
      memwb_alu_result <= 0;
      memwb_rd_reg <= 0;
      memwb_reg_write_reg <= 0;
      memwb_result_src <= 0;
    end else begin
      memwb_mem_read_data <= mem_read_data;
      memwb_alu_result <= exmem_alu_result;
      memwb_rd_reg <= exmem_rd_reg;
      memwb_reg_write_reg <= exmem_reg_write;
      memwb_result_src <= idex_result_src;
    end
  end

  // Outputs for Hazard & Forwarding units
  assign idex_rs1 = idex_rs1_reg;
  assign idex_rs2 = idex_rs2_reg;
  assign exmem_rd = exmem_rd_reg;
  assign exmem_mem_read = exmem_mem_write; // Assuming mem_write is also mem_read active low
  assign memwb_rd = memwb_rd_reg;
  assign memwb_reg_write = memwb_reg_write_reg;

  // Writeback mux select
  logic [31:0] writeback_data;
  always_comb begin
    case (memwb_result_src)
      2'b00: writeback_data = memwb_alu_result;
      2'b01: writeback_data = memwb_mem_read_data;
      2'b10: writeback_data = memwb_alu_result + 4;  // PC+4 for JAL, JALR
      default: writeback_data = memwb_alu_result;
    endcase
  end

endmodule
