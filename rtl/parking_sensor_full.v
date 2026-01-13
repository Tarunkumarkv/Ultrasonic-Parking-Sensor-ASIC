// =============================================================
// TOP-LEVEL MODULE: PARKING SENSOR SYSTEM
// =============================================================
module parking_sensor_top (
    input wire clk,            // 20MHz System Clock
    input wire reset,          // Active-High System Reset
    input wire echo_pulse,     // Input from HC-SR04 Sensor
    output wire trigger_pulse, // 10us Output to Sensor
    output wire alarm_warning  // Safety Alert (Active High)
);

    // --- Internal Wires (The "Nets" connecting the blocks) ---
    wire start_trig;           // FSM -> Trigger Gen
    wire trig_done;            // Trigger Gen -> FSM
    wire en_echo_count;        // FSM -> Echo Counter
    wire clear_regs;           // FSM -> Sub-modules (Reset for new cycle)
    wire [15:0] raw_dist;      // Echo Counter -> Comparator

    // 1. INSTANTIATE TRIGGER GENERATOR
    trigger_generator trig_inst (
        .clk(clk),
        .reset(reset | clear_regs), // Reset on system reset OR new cycle
        .start_trigger(start_trig),
        .trigger_pulse(trigger_pulse),
        .trigger_done(trig_done)
    );

    // 2. INSTANTIATE ECHO COUNTER
    echo_counter echo_inst (
        .clk(clk),
        .reset(reset | clear_regs),
        .echo_pulse(echo_pulse),
        .enable_count(en_echo_count),
        .distance_raw(raw_dist)
    );

    // 3. INSTANTIATE DISTANCE COMPARATOR
    distance_comparator comp_inst (
        .distance_value(raw_dist),
        .alarm_active(alarm_warning)
    );

    // 4. INSTANTIATE CONTROL UNIT (FSM)
    fsm_controller fsm_inst (
        .clk(clk),
        .reset(reset),
        .trigger_done(trig_done),
        .echo_pulse(echo_pulse),
        .start_trigger(start_trig),
        .enable_echo_count(en_echo_count),
        .clear_registers(clear_regs)
    );

endmodule


// =============================================================
// SUB-MODULE 1: TRIGGER GENERATOR (10us Pulse)
// =============================================================
module trigger_generator (
    input wire clk, reset,
    input wire start_trigger,
    output reg trigger_pulse,
    output reg trigger_done
);
    reg [9:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            trigger_pulse <= 0;
            trigger_done <= 0;
        end else if (start_trigger) begin
            if (count < 200) begin
                count <= count + 1;
                trigger_pulse <= 1;
                trigger_done <= 0;
            end else begin
                trigger_pulse <= 0;
                trigger_done <= 1;
            end
        end else begin
            // Reset internal state when not active
            count <= 0;
            trigger_pulse <= 0;
            trigger_done <= 0;
        end
    end
endmodule


// =============================================================
// SUB-MODULE 2: ECHO COUNTER (Time-of-Flight)
// =============================================================
module echo_counter (
    input wire clk, reset,
    input wire echo_pulse,
    input wire enable_count,
    output reg [15:0] distance_raw
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            distance_raw <= 0;
        end else if (enable_count && echo_pulse) begin
            distance_raw <= distance_raw + 1;
        end
    end
endmodule


// =============================================================
// SUB-MODULE 3: DISTANCE COMPARATOR (Safety Logic)
// =============================================================
module distance_comparator (
    input wire [15:0] distance_value,
    output reg alarm_active
);
    always @(*) begin
        // Threshold = 200 ticks. Alarm if Distance < 200 AND Distance > 0
        if (distance_value < 16'd200 && distance_value > 16'd0)
            alarm_active = 1;
        else
            alarm_active = 0;
    end
endmodule


// =============================================================
// SUB-MODULE 4: FSM CONTROLLER (Main Logic)
// =============================================================
module fsm_controller (
    input wire clk, reset,
    input wire trigger_done,
    input wire echo_pulse,
    output reg start_trigger,
    output reg enable_echo_count,
    output reg clear_registers
);
    // State Encoding
    localparam IDLE=3'b000, TRIG=3'b001, WAIT=3'b010, MEASURE=3'b011, ANALYZE=3'b100;
    reg [2:0] current_state, next_state;

    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        next_state = current_state;
        start_trigger = 0; 
        enable_echo_count = 0; 
        clear_registers = 0;

        case (current_state)
            IDLE: begin
                clear_registers = 1; // Clear counters before starting
                next_state = TRIG;
            end
            TRIG: begin
                start_trigger = 1;
                if (trigger_done) next_state = WAIT;
            end
            WAIT: begin
                // In a real system, you might add a timeout here
                if (echo_pulse) next_state = MEASURE;
            end
            MEASURE: begin
                enable_echo_count = 1;
                if (!echo_pulse) next_state = ANALYZE;
            end
            ANALYZE: begin
                // State to hold the comparator result before resetting
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
