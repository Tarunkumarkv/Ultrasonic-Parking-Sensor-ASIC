`timescale 1ns/1ps

module tb_distance_comparator();
    reg [15:0] distance_value;
    wire alarm_active;

    // Instantiate the Unit Under Test (UUT)
    distance_comparator dut (
        .distance_value(distance_value),
        .alarm_active(alarm_active)
    );

    initial begin
        // Setup for GTKWave waveform viewing
        $dumpfile("comparator.vcd");
        $dumpvars(0, tb_distance_comparator);

        // Test Case 1: Object far away (No Alarm)
        distance_value = 16'd500;
        #100;
        
        // Test Case 2: Object at the threshold (No Alarm)
        distance_value = 16'd200;
        #100;

        // Test Case 3: Object inside threshold (Alarm should be 1)
        distance_value = 16'd150;
        #100;

        // Test Case 4: Object very close (Alarm should be 1)
        distance_value = 16'd10;
        #100;

        // Test Case 5: Zero/Invalid distance (No Alarm)
        distance_value = 16'd0;
        #100;

        $display("Comparator verification complete.");
        $finish;
    end
endmodule
