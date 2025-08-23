// Master FSM for 4-byte burst transfer implementing 4-phase req/ack handshake.
// Sends 4 bytes (A0..A3), drives req, waits for ack, indicates done after burst.

module master_fsm(
    input wire clk,     // System clock
    input wire rst,     // Synchronous active-high reset
    input wire ack,     // Acknowledge signal from slave
    output reg req,     // Request signal to slave
    output reg [7:0] data,   // 8-bit data bus output
    output reg done     // 1-cycle pulse indicating burst complete
);

    // States for handshake sequence and burst control
    localparam IDLE      = 3'd0,
               SEND_REQ  = 3'd1,
               WAIT_ACK1 = 3'd2,
               WAIT_ACK2 = 3'd3,
               DROP_REQ  = 3'd4,
               DONE_PULSE= 3'd5;

    reg [2:0] state, next_state;      // FSM current and next state
    reg [1:0] byte_idx, next_byte_idx; // Byte index for burst (0 to 3)

    // Example burst data values
    reg [7:0] burst [0:3];
    initial begin
        burst[0] = 8'hA0;
        burst[1] = 8'hA1;
        burst[2] = 8'hA2;
        burst[3] = 8'hA3;
    end

    // Combinational logic: FSM next state and outputs
    always @(*) begin
        // Default assignments
        next_state    = state;
        next_byte_idx = byte_idx;
        req           = 0;
        data          = burst[byte_idx];
        done          = 0;

        case (state)
            IDLE: begin
                // Start burst by sending first byte
                next_byte_idx = 0;
                next_state = SEND_REQ;
            end
            SEND_REQ: begin
                req = 1;       // Assert request and present data
                if (ack)       // Wait for slave acknowledgment
                    next_state = WAIT_ACK1;
            end
            WAIT_ACK1: begin
                req = 1;       // Keep request asserted while ack high (1st ack cycle)
                next_state = WAIT_ACK2;
            end
            WAIT_ACK2: begin
                req = 1;       // Keep request asserted (2nd ack cycle)
                next_state = DROP_REQ;
            end
            DROP_REQ: begin
                req = 0;       // Drop request after ack cycles completed
                if (!ack) begin  // Wait for slave to release ack
                    if (byte_idx == 2'd3)   // If last byte sent
                        next_state = DONE_PULSE;
                    else begin              // Otherwise proceed to next byte
                        next_byte_idx = byte_idx + 1;
                        next_state = SEND_REQ;
                    end
                end
            end
            DONE_PULSE: begin
                done = 1;    // Pulse done to indicate completion of burst
                next_state = IDLE;
            end
        endcase
    end

    // Sequential logic: update state and byte index on clock edge or reset
    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            byte_idx  <= 0;
        end else begin
            state     <= next_state;
            byte_idx  <= next_byte_idx;
        end
    end

endmodule
