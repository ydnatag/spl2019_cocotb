`timescale 1ns/1ps

module counter_toplevel(
    input clk,
    input rst,
    input enable,
    output [WIDTH-1:0] contador,
    output valid
);
parameter WIDTH = 5;

enable_counter #(.WIDTH(WIDTH))cnt (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .contador(contador),
    .valid(valid)
);

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("./sim_build/waveform.vcd");
        $dumpvars (0, counter_toplevel);
    end
`endif

endmodule
