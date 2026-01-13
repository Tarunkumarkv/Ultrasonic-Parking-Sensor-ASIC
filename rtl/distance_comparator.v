module distance_comparator (
    input wire [15:0] distance_value,
    output reg alarm_active
);
    always @(*) begin
        if (distance_value < 16'd200 && distance_value > 16'd0)
            alarm_active = 1;
        else
            alarm_active = 0;
    end
endmodule
