// Testbench for link_top module, generates clock and reset,
// monitors 'done' to stop simulation, and dumps waveforms.

`timescale 1ns/1ps
`include "link_top.v"

module tb_link_top;
    reg clk;
    reg rst;
    wire done;

    // Instantiate top module
    link_top dut(
        .clk(clk),
        .rst(rst),
        .done(done)
    );

    // Clock: 100 MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Enable waveform dumping
        $dumpfile("link_top.vcd");
        $dumpvars(0, tb_link_top);

        // Reset for 30 ns
        rst = 1;
        #30;
        rst = 0;

        // Wait until done signal asserts or timeout after 20,000 ns
        fork
            begin
                wait(done == 1);
                #50;          // observe final state
                $finish;
            end
            begin
                #20000;
                $display("Simulation timed out without 'done' signal.");
                $finish;
            end
        join
    end
endmodule
