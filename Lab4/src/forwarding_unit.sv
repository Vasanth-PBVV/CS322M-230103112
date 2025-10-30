module forwarding_unit(
  input logic [4:0] EX_rs1,
  input logic [4:0] EX_rs2,
  input logic [4:0] MEM_rd,
  input logic MEM_reg_write,
  input logic [4:0] WB_rd,
  input logic WB_reg_write,

  output logic [1:0] forwardA,
  output logic [1:0] forwardB
);

  always_comb begin
    // Default forwarding: no forwarding
    forwardA = 2'b00;
    forwardB = 2'b00;

    // Forward for EX stage operand A
    if (MEM_reg_write && (MEM_rd != 0) && (MEM_rd == EX_rs1)) begin
      forwardA = 2'b10;
    end else if (WB_reg_write && (WB_rd != 0) && (WB_rd == EX_rs1)) begin
      forwardA = 2'b01;
    end

    // Forward for EX stage operand B
    if (MEM_reg_write && (MEM_rd != 0) && (MEM_rd == EX_rs2)) begin
      forwardB = 2'b10;
    end else if (WB_reg_write && (WB_rd != 0) && (WB_rd == EX_rs2)) begin
      forwardB = 2'b01;
    end
  end

endmodule
