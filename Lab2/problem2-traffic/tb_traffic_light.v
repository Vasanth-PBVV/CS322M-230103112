// Testbench for traffic_light
// Generates clock, reset, and 1 Hz tick. Dumps output to VCD waveform file.

`include "traffic_light.v"
`timescale 1ns/1ps

module tb_traffic_light;
    reg clk;
    reg rst;
    reg tick;
    wire ns_g;
    wire ns_y;
    wire ns_r;
    wire ew_g;
    wire ew_y;
    wire ew_r;

    // Instantiate the DUT
    traffic_light dut (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .ns_g(ns_g),
        .ns_y(ns_y),
        .ns_r(ns_r),
        .ew_g(ew_g),
        .ew_y(ew_y),
        .ew_r(ew_r)
    );

    // 100 MHz clock generation (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        // Waveform dump settings for GTKWave
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        // Reset sequence
        rst = 1;
        tick = 0;
        #30;
        rst = 0;

        // Generate 36 ticks for simulation
        for (i = 0; i < 36; i = i + 1) begin
            tick = 1;
            #10;
            tick = 0;
            #990;
        end

        // Finish simulation after some delay
        #100;
        $finish;
    end

endmodule
