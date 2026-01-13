module tb_fsm_controller();
    reg clk, reset, trigger_done, echo_pulse;
    wire start_trigger, enable_echo_count, clear_registers;

    fsm_controller dut (.*);
    always #25 clk = ~clk;

    initial begin
        $dumpfile("fsm_control.vcd");
        $dumpvars(0, tb_fsm_controller);
        
        clk = 0; reset = 1; trigger_done = 0; echo_pulse = 0;
        #100 reset = 0;
        #100 trigger_done = 1;
        #100 trigger_done = 0; echo_pulse = 1;
        #1000 echo_pulse = 0; 
        #200 $finish;
    end
endmodule
