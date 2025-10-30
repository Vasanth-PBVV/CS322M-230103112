module hazard_detection_unit(
  input logic [4:0] ID_rs1, ID_rs2,    // Source registers of instruction in ID stage
  input logic EX_mem_read,             // MEM read signal of instruction in EX stage
  input logic [4:0] EX_rd,             // Destination register of instruction in EX stage

  output logic stall,
  output logic flush
);

  // Stall when ID instruction uses registers depending on a load in EX stage (load-use hazard)
  // Flush signal is for controlling pipeline flush on branch misprediction or hazard clearing
  always_comb begin
    stall = 0;
    flush = 0;

    if (EX_mem_read && ((EX_rd == ID_rs1) || (EX_rd == ID_rs2))) begin
      stall = 1;  // Stall pipeline
      flush = 0;  // No flush here; stall will prevent IF/ID update
    end
  end

endmodule
