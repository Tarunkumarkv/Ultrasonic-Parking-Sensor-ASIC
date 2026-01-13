module echo_counter (
    input wire clk, reset,
    input wire echo_pulse,        
    input wire enable_count,      
    output reg [15:0] distance_raw
);
    always @(posedge clk or posedge reset) begin
        if (reset) distance_raw <= 0;
        else if (enable_count && echo_pulse) distance_raw <= distance_raw + 1;
    end
endmodule
