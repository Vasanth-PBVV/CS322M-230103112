1. Files Provided
master_fsm.v: Master finite state machine controlling the request (req) signal, sending 4 bytes in burst, and signaling completion with done.

slave_fsm.v: Slave finite state machine that latches incoming data on req, asserts ack for 2 cycles, and holds the last byte received.

link_top.v: Top-level module connecting master_fsm and slave_fsm, passing handshake signals and data.

tb_link_top.v: Testbench to drive the link_top module, generate clock/reset, wait for burst completion (done), and dump waveforms to link_top.vcd.

2. Compilation Instructions
Run the following command in your project directory:

bash
iverilog -o link_top_tb master_fsm.v slave_fsm.v link_top.v tb_link_top.v
This compiles the design and testbench into an executable named link_top_tb.

3. Simulation Instructions
Execute the simulation:

bash
vvp link_top_tb
This will produce the waveform file link_top.vcd.

4. Waveform Visualization
Open the waveform file with GTKWave:

bash
gtkwave link_top.vcd
Observe signals including:

req and data driven by Master FSM

ack signal and last_byte output from Slave FSM

The done signal indicating the full burst completion

Clock and reset signals

Use GTKWave tools to zoom and inspect timing relationships.

5. Expected Behavior
The Master FSM initiates a 4-byte burst, asserting req, putting data on the bus.

The Slave FSM latches the data when req is asserted, then asserts ack for 2 clock cycles to acknowledge reception.

Master sees ack, drops req; Slave subsequently drops ack.

This handshake repeats for exactly 4 bytes.

After the last byte, Master pulses done for 1 clock cycle.

The Slave's last_byte holds the last data value latched.

The handshake timing diagram (req/ack/data) shows the 4-phase protocol for each byte.

The waveform should clearly show 4 repeated handshake cycles and a final done pulse.

6. Notes
Reset is synchronous, active-high.

The signals and the FSM states can be further debugged by including internal signals in the VCD file if desired.

The testbench includes a timeout to avoid infinite simulation hangs in case of issues.

All verification is performed through waveform analysis — no textual console output is required.