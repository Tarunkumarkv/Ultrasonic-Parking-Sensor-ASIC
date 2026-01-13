`timescale 1ns/1ps

module tb_trigger_generator();
    reg clk, reset, start_trigger;
    wire trigger_pulse, trigger_done;

    trigger_generator dut (
        .clk(clk), .reset(reset), 
        .start_trigger(start_trigger),
        .trigger_pulse(trigger_pulse), 
        .trigger_done(trigger_done)
    );

    always #25 clk = ~clk; // 20MHz clock

    initial begin
        $dumpfile("trigger_gen.vcd");
        $dumpvars(0, tb_trigger_generator);
        
        clk = 0; reset = 1; start_trigger = 0;
        #100 reset = 0;
        #100 start_trigger = 1;
        
        wait(trigger_done);
        #100 start_trigger = 0;
        #200 $display("Trigger timing verified.");
        $finish;
    end
endmodule
