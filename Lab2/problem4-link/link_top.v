// Top module which connects master FSM and slave FSM,
// passing handshake and data signals between them.

`include "master_fsm.v"
`include "slave_fsm.v"

module link_top(
    input wire clk,      // Common system clock
    input wire rst,      // Common synchronized reset
    output wire done     // Signal master burst completion
);

    wire req;            // Master-to-slave request
    wire ack;            // Slave-to-master acknowledgment
    wire [7:0] data;     // Data bus from master to slave
    wire [7:0] last_byte; // Last byte latched by slave (optional observation)

    master_fsm master_inst (
        .clk(clk),
        .rst(rst),
        .ack(ack),
        .req(req),
        .data(data),
        .done(done)
    );

    slave_fsm slave_inst (
        .clk(clk),
        .rst(rst),
        .req(req),
        .data_in(data),
        .ack(ack),
        .last_byte(last_byte)
    );
endmodule
