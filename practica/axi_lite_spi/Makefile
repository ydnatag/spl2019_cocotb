export COCOTB_REDUCED_LOG_FMT
export PYTHONPATH:=tests:$(PYTHONPATH)

LANG=verilog
SIM=icarus

VERILOG_SOURCES = ./hdl/spi_master.v \
                  ./hdl/axi_spi.v \
                  ./hdl/axi_lite_slave_int.v

TOPLEVEL=axi_spi
MODULE=test

COCOTB=$(shell cocotb-config --makefiles)
include $(COCOTB)/Makefile.inc
include $(COCOTB)/Makefile.sim

gtkwave:
	gtkwave sim_build/waveform.vcd waveform.gtkw




