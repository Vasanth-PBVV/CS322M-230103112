README: Traffic Light Controller Simulation and Visualization
1. Files
traffic_light.v: Verilog module implementing the Moore FSM controller for NS/EW traffic lights.

tb_traffic_light.v: Testbench that generates clock, reset, and tick for simulation; produces traffic_light_tb.vcd waveform file.

2. Compilation Steps
Open a terminal in your project folder and run:

text
iverilog -o traffic_light_tb traffic_light.v tb_traffic_light.v
This compiles your design and testbench, producing an executable traffic_light_tb.

3. Simulation Steps
Run the simulation to create a VCD waveform file:

text
vvp traffic_light_tb
This will generate traffic_light_tb.vcd in your directory.

4. Visualization Steps
View and analyze the waveform using GTKWave:

text
gtkwave traffic_light_tb.vcd
In GTKWave:

Add signals to the view: clk, rst, tick, ns_g, ns_y, ns_r, ew_g, ew_y, ew_r.

You can zoom in/out and measure tick durations directly.

5. Expected Behavior
The NS and EW traffic lights operate in four phases, controlled by the FSM:

NS Green: 5 ticks (5 seconds)

NS Yellow: 2 ticks

EW Green: 5 ticks

EW Yellow: 2 ticks

Only one light (green/yellow/red) per road is ON at any time.

The tick signal advances the phase every second: with each tick, the FSM increments a per-phase counter and proceeds when the count is complete.

The pattern repeats infinitely: NS gets green/yellow, then EW gets green/yellow.

Use GTKWave to visually verify the durations and transitions for correct timing and mutually exclusive outputs.