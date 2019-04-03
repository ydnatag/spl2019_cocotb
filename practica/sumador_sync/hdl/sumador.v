`timescale 1ns/1ps

module sumador(
    input clk,
    input rst,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [WIDTH-1:0] sum,
    output reg overflow,
    output reg carry_out
);
parameter WIDTH = 3;
wire sign_a, sign_b, sign_aux_sum;
wire [WIDTH:0] aux_sum;

assign aux_sum = {a[WIDTH-1], a} + {b[WIDTH-1],b};
assign sign_a = a[WIDTH-1];
assign sign_b = b[WIDTH-1];
assign sign_sum = aux_sum[WIDTH-1];

always @(posedge clk) begin
    if (rst) begin
        sum <= 'd0;
        overflow <= 'd0;
        carry_out <= 'd0;
    end else begin
        sum <= aux_sum[WIDTH-1:0];
        overflow <= ( sign_a &  sign_b & ~sign_sum) |
                    (~sign_a & ~sign_b &  sign_sum);
        carry_out <= aux_sum[WIDTH];
    end
end


`ifdef COCOTB_SIM
    initial begin
        $dumpfile("./sim_build/waveform.vcd");
        $dumpvars (0, sumador);
    end
`endif

endmodule
