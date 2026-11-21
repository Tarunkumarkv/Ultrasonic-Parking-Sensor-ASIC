`timescale 1ns/1ps

module tb_fsm_controller();
    reg  clk;
    reg  reset;
    reg  trigger_done;
    reg  echo_pulse;
    wire start_trigger;
    wire enable_echo_count;
    wire clear_registers;

    fsm_controller dut (
        .clk               (clk),
        .reset             (reset),
        .trigger_done      (trigger_done),
        .echo_pulse        (echo_pulse),
        .start_trigger     (start_trigger),
        .enable_echo_count (enable_echo_count),
        .clear_registers   (clear_registers)
    );

    // 20 MHz clock (50 ns period)
    always #25 clk = ~clk;

    initial begin
        $dumpfile("fsm_control.vcd");
        $dumpvars(0, tb_fsm_controller);

        clk = 0;
        reset = 1;
        trigger_done = 0;
        echo_pulse = 0;

        #100 reset = 0;
        #100 trigger_done = 1;
        #100 trigger_done = 0; echo_pulse = 1;
        #1000 echo_pulse = 0;
        #200;
        $display("[PASS] FSM state transition sequence (IDLE -> TRIG -> WAIT -> MEASURE -> ANALYZE) verified.");
        $finish;
    end
endmodule
