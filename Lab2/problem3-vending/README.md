1. Files
vending_mealy.v: Verilog module implementing a Mealy FSM vending machine that accepts coins 5 or 10, dispenses when total ≥ 20, and returns 5 change if total = 25.

tb_vending_mealy.v: Testbench generating clock, reset, and coin inputs to exercise the FSM. Produces vending_mealy_tb.vcd waveform file.

2. Compilation Steps
Open a terminal in your project folder and run:

text
iverilog -o vending_mealy_tb vending_mealy.v tb_vending_mealy.v
This compiles your source and testbench into an executable vending_mealy_tb.

3. Simulation Steps
Run the simulation to generate the waveform file:

text
vvp vending_mealy_tb
This will create the file vending_mealy_tb.vcd.

4. Visualization Steps
Open the generated waveform file using GTKWave:

text
gtkwave vending_mealy_tb.vcd
Inside GTKWave:

Add signals clk, rst, coin, dispense, and chg5 to analyze operation.

Observe whenever coin inputs cause state transitions.

Confirm that the dispense pulse goes high for exactly one clock cycle when total ≥ 20.

Confirm that the chg5 pulse also goes high for one clock cycle only when returning 5 change (i.e., total = 25).

5. Expected Behavior Summary
The machine maintains totals of 0, 5, 10, or 15 cents as states.

Coins are input as 2-bit values: 01 = 5, 10 = 10, 00 = idle (no coin), 11 = ignored.

When total reaches or exceeds 20 cents, a vending pulse (dispense) is generated for 1 clock cycle.

If total is exactly 25 cents after a coin input, a chg5 pulse signals 5-cent change for 1 clock cycle.

After vending, the total resets to 0 to accept new coins.