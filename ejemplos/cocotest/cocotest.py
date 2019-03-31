import cocotb
from cocotb.triggers import Timer

@cocotb.test()
def hello_world(dut):
    cocotb.log.info("Hello World")
    yield Timer(1, units='us')

@cocotb.test()
def world_hello(dut):
    cocotb.log.info("World Hello")
    yield Timer(1, units='us')
