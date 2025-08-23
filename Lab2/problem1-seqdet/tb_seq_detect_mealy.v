// Testbench for seq_detect_mealy; drives overlapping pattern bits
`timescale 1ns/1ps
`include "seq_detect_mealy.v"

module tb_seq_detect_mealy;
    reg clk;
    reg rst;
    reg din;
    wire y;

    // Instantiate DUT
    seq_detect_mealy dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .y(y)
    );

    // 100 MHz clock (period 10 ns)
    initial clk = 0;
    always #5 clk = ~clk;

    // Example input stream with overlaps: 1101101101
    reg [15:0] bitstream;
    integer i;

    initial begin
        $dumpfile("seq_detect_mealy.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        // Test pattern: multiple overlapping 1101s, also edges
        bitstream = 16'b0110110110110100; // Rightmost clock first: left aligns with time
        // Bit indices for expected output pulses: cycles 4, 8, 12

        rst = 1; din = 0;
        #20;
        rst = 0;

        // Play the stream (from bitstream[15]..bitstream)
        for (i = 15; i >= 0; i = i - 1) begin
            din = bitstream[i];
            #10;
        end

        // Some idle after pattern
        din = 0;
        #100;
        $finish;
    end

endmodule
