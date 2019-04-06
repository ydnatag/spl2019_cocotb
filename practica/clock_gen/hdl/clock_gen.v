`timescale 1ns/1ps

module clock_gen(
    input clk
);

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("./sim_build/waveform.vcd");
        $dumpvars (0, clock_gen);
    end
`endif

endmodule
