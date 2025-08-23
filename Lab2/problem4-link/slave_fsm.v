// Slave FSM to latch incoming data on req, assert ack for two cycles,
// and hold the last byte received for observation by the testbench.

module slave_fsm(
    input wire clk,            // System clock
    input wire rst,            // Synchronous active-high reset
    input wire req,            // Request from master
    input wire [7:0] data_in,  // 8-bit data bus input from master
    output reg ack,            // Acknowledge signal to master
    output reg [7:0] last_byte // Holds last byte received, observable for testbench
);

    // State definitions for slave handshake
    localparam IDLE    = 2'd0,
               LATCH   = 2'd1,
               HOLDACK = 2'd2,
               DROPACK = 2'd3;

    reg [1:0] state, next_state;       
    reg ack_count, next_ack_count;      // Count cycles ack held high (2 cycles)

    always @(*) begin
        // Default values for next state and ack count
        next_state = state;
        next_ack_count = ack_count;
        ack = 0;

        case (state)
            IDLE: begin
                if (req)       // When master asserts req, latch data
                    next_state = LATCH;
            end
            LATCH: begin
                ack = 1;       // Assert ack showing valid data latched
                next_ack_count = 0;
                next_state = HOLDACK;
            end
            HOLDACK: begin
                ack = 1;       // Hold ack high for the second cycle
                if (ack_count) // Completed 2 cycles of ack high
                    next_state = DROPACK;
                else
                    next_ack_count = ack_count + 1;
            end
            DROPACK: begin
                ack = 0;       // Ack dropped
                if (!req)     // Wait for master to drop req
                    next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Sequential logic for state, ack cycle count, and latching data
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ack_count <= 0;
            last_byte <= 8'd0;
        end else begin
            state <= next_state;
            ack_count <= next_ack_count;
            if (next_state == LATCH)
                last_byte <= data_in;   // Latch data on entering LATCH state
        end
    end

endmodule
