// Testbench for vending_mealy; generates VCD, no terminal output.
`include "vending_mealy.v"
`timescale 1ns/1ps

module tb_vending_mealy;
    reg clk;
    reg rst;
    reg [1:0] coin;
    wire dispense;
    wire chg5;

    // DUT instantiation
    vending_mealy dut (
        .clk(clk),
        .rst(rst),
        .coin(coin),
        .dispense(dispense),
        .chg5(chg5)
    );

    // Clock generation: 10ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("vending_mealy.vcd");
        $dumpvars(0, tb_vending_mealy);

        // Reset and initial idle
        rst = 1; coin = 2'b00;
        #30;
        rst = 0;

        // Sequence: 5, 5, 10 (==20): vend
        coin = 2'b01; #10; coin = 2'b00; #10;
        coin = 2'b01; #10; coin = 2'b00; #10;
        coin = 2'b10; #10; coin = 2'b00; #10; // vend expected

        // Sequence: 10, 10 (==20): vend
        coin = 2'b10; #10; coin = 2'b00; #10;
        coin = 2'b10; #10; coin = 2'b00; #10; // vend expected

        // Sequence: 5, 5, 5, 10 (==25): vend + chg5
        coin = 2'b01; #10; coin = 2'b00; #10;
        coin = 2'b01; #10; coin = 2'b00; #10;
        coin = 2'b01; #10; coin = 2'b00; #10;
        coin = 2'b10; #10; coin = 2'b00; #10; // vend and chg5 expected

        // Idle, coin=00 and coin=11 ignored
        coin = 2'b00; #20;
        coin = 2'b11; #20;

        // End simulation
        #100;
        $finish;
    end

endmodule
