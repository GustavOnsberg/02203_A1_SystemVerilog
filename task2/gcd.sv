// -----------------------------------------------------------------------------
//
//  Title      :  System Verilog FSMD implementation template for GCD
//             :
//  Developers :  Otto Westy Rasmussen
//             :
//  Purpose    :  This is a template for the FSMD (finite state machine with datapath) 
//             :  implementation of the GCD circuit
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
    typedef enum logic [3 : 0] { 
        S0,
        S1, 
        S2, 
        S3, 
        S4, 
        S5, 
        S6, 
        S7, 
        S8, 
        S9, 
        S10 } state_t; 
    
    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b;
    
    state_t state, next_state;
    
    // Combinatorial logic
    always_comb begin
        //Default
        next_state = state;
        next_reg_a = reg_a;
        next_reg_b = reg_b;
        ack = 1'b1;
        C = reg_a;
        
        case (state)
            S0 : begin
                if (req) next_state = S1;
                end
            S1 : begin
                next_reg_a = AB;
                next_state = S2;
                end
            S2 : begin
                ack = 1;
                if (!req) next_state = S3;
                end
            S3 : begin
                ack = 0;
                if (req) next_state = S4;
                end
            S4 : begin
                next_reg_b = AB;
                next_state = S5;
                end
            S5 : begin
                if (reg_a > reg_b) next_state = S6;
                else if (reg_a < reg_b) next_state = S7;
                else if (reg_a == reg_b) next_state = S8;
                end
            S6 : begin  
                next_reg_a = reg_a - reg_b;
                next_state = S5;
                end
            S7 : begin  
                next_reg_b = reg_b - reg_a;
                next_state = S5;
                end
            S8 : begin  
                C = reg_a;
                next_state = S9;
                end
            S9 : begin  
                ack = 1'b1;
                if (!req) next_state = S10;
                end
            S10 : begin
                ack = 0;
                next_state = S0;
                end             
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