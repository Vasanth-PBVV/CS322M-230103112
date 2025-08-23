// Traffic Light Controller (Moore FSM)
// Controls NS/EW lights; NS green 5s, NS yellow 2s, EW green 5s, EW yellow 2s. Repeats.
// Inputs:
//   clk: system clock
//   rst: reset, synchronous, active-high
//   tick: 1 Hz pulse, 1 cycle wide
// Outputs: each direction's green/yellow/red, one active at a time

module traffic_light(
    input wire clk,
    input wire rst,
    input wire tick,
    output reg ns_g, ns_y, ns_r,
    output reg ew_g, ew_y, ew_r
);

    // State encoding for FSM
    localparam S_NS_G = 2'b00,   // North-South Green
               S_NS_Y = 2'b01,   // North-South Yellow
               S_EW_G = 2'b10,   // East-West Green
               S_EW_Y = 2'b11;   // East-West Yellow

    reg [1:0] state, next_state;
    reg [2:0] tick_count, next_tick_count; // up to 5

    // Next state and tick count logic
    always @(*) begin
        next_state = state;
        next_tick_count = tick_count;

        case (state)
            S_NS_G: begin
                if (tick) begin
                    if (tick_count == 3'd4) begin
                        next_state = S_NS_Y;
                        next_tick_count = 0;
                    end else begin
                        next_tick_count = tick_count + 1;
                    end
                end
            end
            S_NS_Y: begin
                if (tick) begin
                    if (tick_count == 3'd1) begin
                        next_state = S_EW_G;
                        next_tick_count = 0;
                    end else begin
                        next_tick_count = tick_count + 1;
                    end
                end
            end
            S_EW_G: begin
                if (tick) begin
                    if (tick_count == 3'd4) begin
                        next_state = S_EW_Y;
                        next_tick_count = 0;
                    end else begin
                        next_tick_count = tick_count + 1;
                    end
                end
            end
            S_EW_Y: begin
                if (tick) begin
                    if (tick_count == 3'd1) begin
                        next_state = S_NS_G;
                        next_tick_count = 0;
                    end else begin
                        next_tick_count = tick_count + 1;
                    end
                end
            end
            default: begin
                next_state = S_NS_G;
                next_tick_count = 0;
            end
        endcase
    end

    // Registers for state and tick counter
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_G;
            tick_count <= 0;
        end else begin
            state <= next_state;
            tick_count <= next_tick_count;
        end
    end

    // Output logic (Moore machine: only depends on state)
    always @(*) begin
        // Default to all RED
        ns_g = 0; ns_y = 0; ns_r = 0;
        ew_g = 0; ew_y = 0; ew_r = 0;

        case (state)
            S_NS_G: begin
                ns_g = 1; ns_y = 0; ns_r = 0;
                ew_g = 0; ew_y = 0; ew_r = 1;
            end
            S_NS_Y: begin
                ns_g = 0; ns_y = 1; ns_r = 0;
                ew_g = 0; ew_y = 0; ew_r = 1;
            end
            S_EW_G: begin
                ns_g = 0; ns_y = 0; ns_r = 1;
                ew_g = 1; ew_y = 0; ew_r = 0;
            end
            S_EW_Y: begin
                ns_g = 0; ns_y = 0; ns_r = 1;
                ew_g = 0; ew_y = 1; ew_r = 0;
            end
            default: begin
                ns_g = 1; ns_y = 0; ns_r = 0;
                ew_g = 0; ew_y = 0; ew_r = 1;
            end
        endcase
    end

endmodule
