export COCOTB_REDUCED_LOG_FMT
export PYTHONPATH:=tests:$(PYTHONPATH)

LANG=verilog
SIM=icarus

VERILOG_SOURCES=./hdl/counter_toplevel.v \
                ./hdl/enable_counter.v

TOPLEVEL=counter_toplevel
MODULE ?= all

COCOTB=$(shell cocotb-config --makefiles)
include $(COCOTB)/Makefile.inc
include $(COCOTB)/Makefile.sim

gtkwave:
	gtkwave sim_build/waveform.vcd waveform.gtkw

