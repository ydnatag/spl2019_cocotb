`timescale 1ns/1ps

module sumador(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] sum,
    output overflow,
    output carry_out
);
parameter WIDTH = 3;
wire sign_a, sign_b, sign_aux_sum;
wire [WIDTH:0] aux_sum;

assign aux_sum = {a[WIDTH-1], a} + {b[WIDTH-1],b};
assign sum = aux_sum[WIDTH-1:0];
assign sign_a = a[WIDTH-1];
assign sign_b = b[WIDTH-1];
assign sign_sum = aux_sum[WIDTH-1];

assign carry_out = aux_sum[WIDTH];
assign overflow = ( sign_a &  sign_b & ~sign_sum) | (~sign_a & ~sign_b &  sign_sum);


`ifdef COCOTB_SIM
    initial begin
        $dumpfile("./sim_build/waveform.vcd");
        $dumpvars (0, sumador);
    end
`endif

endmodule
