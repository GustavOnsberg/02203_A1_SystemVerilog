// -----------------------------------------------------------------------------
//
//  Title      :  System Verilog optimized FSMD implementation of GCD (Task 3)
//             :
//  Developers :  Otto Westy Rasmussen
//             :
//  Purpose    :  Same port list as the Task 2 gcd module, but a different
//             :  architecture: the compare and the subtraction are done in the
//             :  same clock cycle (A-B and B-A are available in parallel), so
//             :  each iteration of Euclid's algorithm takes one cycle instead
//             :  of two. This costs extra datapath logic (comparators and a
//             :  second subtractor) compared to the one-ALU design in Task 2.
//             :
//  Revision   :  02203 fall 2025 v.1.0
//
// -----------------------------------------------------------------------------


module gcd (
    input  logic          clk,    // The clock signal.
    input  logic          reset,  // Reset the module.
    input  logic          req,    // Start computation.
    input  logic [15 : 0] AB,     // The two operands. One at a time.
    output logic          ack,    // Input received / Computation is complete.
    output logic [15 : 0] C       // The result.
);
    typedef enum logic [2 : 0] {
        S0,   // Idle: wait for req, latch operand A
        S2,   // ack=1 until req is released (handshake 1)
        S3,   // ack=0: wait for req, latch operand B
        S5,   // Compare and subtract in the same cycle
        S9,   // ack=1, result on C, until req is released (handshake 2)
        S10   // ack=0, back to idle
    } state_t;

    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b;

    state_t state, next_state;

    // Combinatorial logic
    always_comb begin
        // Default: hold state and registers, ack is only raised in S2 and S9,
        // so it depends on the state only.
        next_state = state;
        next_reg_a = reg_a;
        next_reg_b = reg_b;
        ack = 1'b0;
        C = reg_a;

        case (state)
            S0 : begin
                if (req) begin
                    next_reg_a = AB;
                    next_state = S2;
                end
            end
            S2 : begin
                ack = 1'b1;
                if (!req) next_state = S3;
            end
            S3 : begin
                if (req) begin
                    next_reg_b = AB;
                    next_state = S5;
                end
            end
            S5 : begin
                if (reg_a > reg_b) next_reg_a = reg_a - reg_b;
                else if (reg_a < reg_b) next_reg_b = reg_b - reg_a;
                else next_state = S9;
            end
            S9 : begin
                ack = 1'b1;
                if (!req) begin
                    ack = 0;
                    next_state = S0;
                    end;
            end
            default : next_state = S0;
        endcase
    end

    // Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            reg_a <= 0;
            reg_b <= 0;
        end else begin
            state <= next_state;
            reg_a <= next_reg_a;
            reg_b <= next_reg_b;
        end
    end
endmodule
