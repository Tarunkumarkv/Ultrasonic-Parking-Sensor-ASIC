module fsm_controller (
    input wire clk, reset,
    input wire trigger_done,      
    input wire echo_pulse,        
    output reg start_trigger,     
    output reg enable_echo_count, 
    output reg clear_registers    
);
    localparam IDLE=3'b000, TRIG=3'b001, WAIT=3'b010, MEASURE=3'b011, ANALYZE=3'b100;
    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        start_trigger = 0; enable_echo_count = 0; clear_registers = 0;

        case (current_state)
            IDLE: begin clear_registers = 1; next_state = TRIG; end
            TRIG: begin start_trigger = 1; if (trigger_done) next_state = WAIT; end
            WAIT: begin if (echo_pulse) next_state = MEASURE; end
            MEASURE: begin enable_echo_count = 1; if (!echo_pulse) next_state = ANALYZE; end
            ANALYZE: begin next_state = IDLE; end
            default: next_state = IDLE;
        endcase
    end
endmodule
