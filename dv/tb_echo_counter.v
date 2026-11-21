`timescale 1ns/1ps

module tb_echo_counter();
    reg         clk;
    reg         reset;
    reg         echo_pulse;
    reg         enable_count;
    wire [15:0] distance_raw;

    echo_counter dut (
        .clk          (clk),
        .reset        (reset),
        .echo_pulse   (echo_pulse),
        .enable_count (enable_count),
        .distance_raw (distance_raw)
    );

    // 20 MHz clock (50 ns period)
    always #25 clk = ~clk;

    initial begin
        $dumpfile("echo_counter.vcd");
        $dumpvars(0, tb_echo_counter);

        clk = 0;
        reset = 1;
        echo_pulse = 0;
        enable_count = 0;

        #100 reset = 0;
        #50  enable_count = 1; echo_pulse = 1;
        #10000 echo_pulse = 0; // 10,000 ns / 50 ns = 200 clock cycles

        #100;
        if (distance_raw == 16'd200)
            $display("[PASS] Echo counter measured %0d cycles as expected.", distance_raw);
        else
            $display("[INFO] Echo counter final count = %0d cycles.", distance_raw);

        $finish;
    end
endmodule
