`timescale 1ns/1ps

module tb_parking_system();
    reg clk, reset, echo_pulse;
    wire trigger_pulse, alarm_warning;

    // Instantiate the Top Module
    parking_sensor_top uut (
        .clk(clk),
        .reset(reset),
        .echo_pulse(echo_pulse),
        .trigger_pulse(trigger_pulse),
        .alarm_warning(alarm_warning)
    );

    // Clock Generation (20MHz)
    always #25 clk = ~clk;

    initial begin
        // Setup Waveform Dump
        $dumpfile("full_system.vcd");
        $dumpvars(0, tb_parking_system);

        // Initialize Inputs
        clk = 0; reset = 1; echo_pulse = 0;
        
        // 1. Release Reset
        #100 reset = 0;

        // 2. Wait for Trigger Pulse (System will generate this automatically)
        wait(trigger_pulse == 1);
        $display("Time %0t: Trigger Pulse Started", $time);
        
        wait(trigger_pulse == 0);
        $display("Time %0t: Trigger Pulse Ended", $time);

        // 3. Simulate Sensor Response (Echo Pulse)
        // Scenario: Object is CLOSE (Distance < 200 ticks)
        #500 echo_pulse = 1;
        #2500 echo_pulse = 0; // Duration = 2.5us (approx 50 ticks)
        
        // 4. Observe Alarm
        #200;
        if (alarm_warning == 1) 
            $display("SUCCESS: Alarm Triggered correctly for close object!");
        else
            $display("FAILURE: Alarm did not trigger.");

        #500 $finish;
    end
endmodule
