README: Mealy Sequence Detector for Pattern "1101" with Overlap
1. Files
seq_detect_mealy.v: Verilog module implementing a Mealy finite state machine to detect the overlapping pattern "1101" on serial input din.

tb_seq_detect_mealy.v: Testbench sending serial bit streams (including overlapping patterns) and generating a VCD waveform file for analysis.

2. Compilation Instructions
Open a terminal in your project folder and run:

text
iverilog -o seq_detect_mealy_tb seq_detect_mealy.v tb_seq_detect_mealy.v
This compiles the design and testbench, producing an executable called seq_detect_mealy_tb.

3. Simulation Instructions
Run the simulation to generate the waveform:

text
vvp seq_detect_mealy_tb
This creates the waveform file seq_detect_mealy_tb.vcd.

4. Visualization Instructions
Open the VCD file in GTKWave for waveform viewing:

text
gtkwave seq_detect_mealy_tb.vcd
Add signals clk, rst, din, and output y to the viewer.

5. Expected Behavior
The FSM detects the serial bit pattern "1101" on din, allowing overlapping patterns.

Output y goes high for exactly one clock cycle immediately when the last bit of the pattern arrives.

The testbench drives overlapping patterns such as 1101101101 to demonstrate detection on overlapping sequences.

Pulses of y appear at the clock cycles where the pattern completes (e.g., indices 4, 8, 12 in the example).

The reset is synchronous and active-high.

Use GTKWave to verify correct timing of pulse outputs and pattern detection.