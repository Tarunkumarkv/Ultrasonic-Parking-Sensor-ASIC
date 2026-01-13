module tb_echo_counter();
    reg clk, reset, echo_pulse, enable_count;
    wire [15:0] distance_raw;

    echo_counter dut (.*);
    always #25 clk = ~clk;

    initial begin
        $dumpfile("echo_counter.vcd");
        $dumpvars(0, tb_echo_counter);
        
        clk = 0; reset = 1; echo_pulse = 0; enable_count = 0;
        #100 reset = 0;
        #50 enable_count = 1; echo_pulse = 1;
        #10000 echo_pulse = 0;
        #100 $finish;
    end
endmodule
