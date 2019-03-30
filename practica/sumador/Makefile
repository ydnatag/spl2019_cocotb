export COCOTB_REDUCED_LOG_FMT
export PYTHONPATH:=tests:$(PYTHONPATH)

LANG=verilog
SIM=icarus

VERILOG_SOURCES=./hdl/sumador.v \

TOPLEVEL=sumador
MODULE ?= test

COCOTB=$(shell cocotb-config --makefiles)
include $(COCOTB)/Makefile.inc
include $(COCOTB)/Makefile.sim

gtkwave:
	gtkwave sim_build/waveform.vcd waveform.gtkw

