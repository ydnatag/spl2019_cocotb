
module enable_counter #(parameter WIDTH = 10)(
    input clk,
    input rst,
    input enable,
    output reg [WIDTH-1:0] contador,
    output reg valid
);


always@(posedge clk) begin
    if (rst) begin
        contador <= 'd0;
        valid <= 'd0;
    end else begin
        if (enable) contador <= contador + 'd1;
        valid <= enable;
    end
end

endmodule
