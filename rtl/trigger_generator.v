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
            count <= 0;
            trigger_pulse <= 0;
            trigger_done <= 0;
        end
    end
endmodule
