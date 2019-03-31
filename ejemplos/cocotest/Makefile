LANG=verilog

VERILOG_SOURCES=./example.v
ifeq ($(LANG), verilog)
SIM = icarus
VERILOG_SOURCES=./example.v
endif

ifeq (${LANG}, vhdl)
SIM = ghdl
VHDL_SOURCES=./example.vhdl
endif

TOPLEVEL=example
MODULE=cocotest
TESTCASE=hello_world,world_hello

export COCOTB_REDUCED_LOG_FMT
COCOTB=$(shell cocotb-config --makefiles)
include $(COCOTB)/Makefile.inc
include $(COCOTB)/Makefile.sim
