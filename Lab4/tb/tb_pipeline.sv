`timescale 1ns/1ps
module tb_pipeline;

  logic clk;
  logic reset;

  // Output signals to monitor
  logic [31:0] result_data;
  logic done;

  // Instantiate the top-level pipelined processor
  riscvpipeline dut (
    .clk(clk),
    .reset(reset)
    // Connect other ports if necessary
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz clock

  // Reset logic
  initial begin
    reset = 1;
    #20;
    reset = 0;
  end

  // Test program loading
  initial begin
    // Load the test program into instruction memory
    // Simulation-dependent syntax: may use $readmemh in your IMEM module
    // Assuming IMEM loads "rvx10_pipeline.hex" on reset or via specific signals

    // Wait for some time for processor to finish
    #10000; // adjust depending on program length

    // Check results - Example: memory address 100 should contain 25 (0x19)
    // Assuming memory interface or internal wires to check result

    if (/* memory at 100 == 25 */) begin
      $display("Test PASSED: Memory[100] = 25");
    end else begin
      $display("Test FAILED: Wrong result in Memory[100]");
    end

    $stop;
  end

  // Waveform dump for GTKWave
  initial begin
    $dumpfile("pipeline.vcd");
    $dumpvars(0, tb_pipeline);
  end

endmodule
