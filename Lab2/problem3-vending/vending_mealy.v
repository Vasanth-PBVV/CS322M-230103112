// Vending Machine Mealy FSM
// Accepts coins of 5 or 10, vends when total >= 20, returns 5-change if total==25.
// States: sums 0, 5, 10, 15. Mealy outputs depend on state+coin.

module vending_mealy(
    input wire clk,
    input wire rst,                // active-high synchronous reset
    input wire [1:0] coin,         // 01=5, 10=10, 00=idle, (11 ignored)
    output reg dispense,           // 1 clk pulse when item dispensed
    output reg chg5                // 1 clk pulse when returning 5 change
);

    // State encoding for balance
    localparam S0 = 2'b00, // 0
               S5 = 2'b01, // 5
               S10 = 2'b10,// 10
               S15 = 2'b11;// 15

    reg [1:0] state, next_state;

    // Mealy outputs (combinational)
    reg dispense_comb, chg5_comb;

    // Next state logic and outputs
    always @(*) begin
        // Defaults
        next_state = state;
        dispense_comb = 0;
        chg5_comb = 0;

        case (state)
            S0: begin
                // Need minimum 20, ignore coin=00 and coin=11
                case (coin)
                    2'b01: next_state = S5;      // Insert 5
                    2'b10: next_state = S10;     // Insert 10
                    default: next_state = S0;
                endcase
            end
            S5: begin
                case (coin)
                    2'b01: next_state = S10;
                    2'b10: next_state = S15;
                    default: next_state = S5;
                endcase
            end
            S10: begin
                case (coin)
                    2'b01: next_state = S15;
                    2'b10: begin
                        next_state = S0;           // 10+10=20, vend!
                        dispense_comb = 1;
                    end
                    default: next_state = S10;
                endcase
            end
            S15: begin
                case (coin)
                    2'b01: begin
                        // 15+5=20, vend!
                        next_state = S0;
                        dispense_comb = 1;
                    end
                    2'b10: begin
                        // 15+10=25, vend + change
                        next_state = S0;
                        dispense_comb = 1;
                        chg5_comb = 1;
                    end
                    default: next_state = S15;
                endcase
            end
            default: next_state = S0;
        endcase
    end

    // Sequential state update and Mealy output register
    always @(posedge clk) begin
        if (rst) begin
            state <= S0;
            dispense <= 0;
            chg5 <= 0;
        end else begin
            state <= next_state;
            dispense <= dispense_comb;
            chg5 <= chg5_comb;
        end
    end

endmodule
