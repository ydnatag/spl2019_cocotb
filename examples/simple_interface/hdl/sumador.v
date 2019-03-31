`timescale 1ns/1ps

module sumador(
    input clk,
    input rst,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input input_valid,
    output input_ack,

    output reg [WIDTH-1:0] sum,
    output reg overflow,
    output reg carry_out,
    output reg output_valid,
    input output_ack
);
parameter WIDTH = 3;

wire input_hs, output_hs;

assign input_hs = input_ack & input_valid;
assign output_hs = output_ack & output_valid;
assign input_ack = (output_valid == 'd0)? input_valid :
                                          input_valid & output_hs;

wire sign_a, sign_b, sign_aux_sum;
wire [WIDTH:0] aux_sum;

assign aux_sum = {1'b0, a} + {1'b0,b};
assign sign_a = a[WIDTH-1];
assign sign_b = b[WIDTH-1];
assign sign_sum = aux_sum[WIDTH-1];


always @(posedge clk) begin
    if (rst) begin
        sum <= 'd0;
        overflow <= 'd0;
        carry_out <= 'd0;
        output_valid <= 'd0;
    end else begin
        if (output_hs) output_valid <= 'd0;
        if (input_hs) begin
            output_valid <= 'd1;
            sum <= aux_sum[WIDTH-1:0];
            overflow <= ( sign_a &  sign_b & ~sign_sum) |
                        (~sign_a & ~sign_b &  sign_sum);
            carry_out <= aux_sum[WIDTH];
        end
    end
end

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("./sim_build/waveform.vcd");
        $dumpvars (0, sumador);
    end
`endif

endmodule
