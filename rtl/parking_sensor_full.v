// =============================================================
// TOP-LEVEL MODULE: PARKING SENSOR SYSTEM (20 MHz Digital Core)
// Target Node: SkyWater 130nm (sky130_fd_sc_hd) via OpenLane 2
// =============================================================
`timescale 1ns/1ps

module parking_sensor_top (
    input  wire clk,           // 20 MHz System Clock (50 ns period)
    input  wire reset,         // Active-High Asynchronous System Reset
    input  wire echo_pulse,    // Echo Time-of-Flight Input from HC-SR04
    output wire trigger_pulse, // 10 us Trigger Output to HC-SR04 (200 cycles)
    output wire alarm_warning  // Proximity Safety Alert (Active High)
);

    // Internal control and datapath nets
    wire        start_trig;     // FSM -> Trigger Generator
    wire        trig_done;      // Trigger Generator -> FSM
    wire        en_echo_count;  // FSM -> Echo Counter
    wire        clear_regs;     // FSM -> Datapath Counters (cycle reset)
    wire [15:0] raw_dist;       // Echo Counter -> Magnitude Comparator

    // 1. Trigger Generator (10-bit counter: 200 cycles @ 20 MHz = 10 us pulse)
    trigger_generator trig_inst (
        .clk           (clk),
        .reset         (reset | clear_regs),
        .start_trigger (start_trig),
        .trigger_pulse (trigger_pulse),
        .trigger_done  (trig_done)
    );

    // 2. Echo Counter (16-bit time-of-flight pulse width counter)
    echo_counter echo_inst (
        .clk           (clk),
        .reset         (reset | clear_regs),
        .echo_pulse    (echo_pulse),
        .enable_count  (en_echo_count),
        .distance_raw  (raw_dist)
    );

    // 3. Distance Comparator (combinational threshold window: 0 < count < 200)
    distance_comparator comp_inst (
        .distance_value (raw_dist),
        .alarm_active   (alarm_warning)
    );

    // 4. Central 5-State FSM Controller (IDLE -> TRIG -> WAIT -> MEASURE -> ANALYZE)
    fsm_controller fsm_inst (
        .clk               (clk),
        .reset             (reset),
        .trigger_done      (trig_done),
        .echo_pulse        (echo_pulse),
        .start_trigger     (start_trig),
        .enable_echo_count (en_echo_count),
        .clear_registers   (clear_regs)
    );

endmodule
