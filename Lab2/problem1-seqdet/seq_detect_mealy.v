// Mealy sequence detector for "1101" with overlap, output 1-cycle pulse on detection.

module seq_detect_mealy(
    input wire clk,
    input wire rst,    // synchronous, active-high
    input wire din,    // serial input bit (one per clock)
    output reg y       // 1-cycle pulse on ...1101 pattern
);

    // State encoding (tracks progress on "1101")
    localparam S0 = 2'b00,  // initial (no match yet)
               S1 = 2'b01,  // seen '1'
               S2 = 2'b10,  // seen "11"
               S3 = 2'b11;  // seen "110"

    reg [1:0] state, next_state;
    reg y_comb;

    // Next state and Mealy output logic
    always @(*) begin
        next_state = state;
        y_comb = 0;

        case (state)
            S0: begin
                if (din)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                if (din)
                    next_state = S2;
                else
                    next_state = S0;
            end
            S2: begin
                if (din)
                    next_state = S2; // Stay in S2 (overlap on '1')
                else
                    next_state = S3;
            end
            S3: begin
                if (din) begin
                    next_state = S1; // Overlap: first '1' of next possible pattern
                    y_comb = 1;      // Detected "1101"!
                end else begin
                    next_state = S0;
                end
            end
            default: next_state = S0;
        endcase
    end

    // Registers
    always @(posedge clk) begin
        if (rst) begin
            state <= S0;
            y <= 0;
        end else begin
            state <= next_state;
            y <= y_comb;
        end
    end

endmodule
