import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ClockCycles, Event
from cocotb.clock import Clock
from cocotb.result import TestError, TestFailure, TestSuccess

from random import randint

@cocotb.coroutine
def reset(dut):
    """ Corrutina de reset """

    dut.enable <= 0
    dut.rst <= 1
    for _ in range(5):
        yield RisingEdge(dut.clk)
    dut.rst <= 0

@cocotb.coroutine
def logger(dut):
    """ Por cada clock lee la salida """
    for _ in range(2**int(dut.cnt.WIDTH)):
        yield RisingEdge(dut.clk)
        readed = dut.contador.value.integer
        cocotb.log.info("[ logger ] contador = %d" % readed)

@cocotb.test()
def always_enable(dut):
    """ Test con enable siempre en 1 """

    cocotb.fork(Clock(dut.clk, 10, units='ns').start())
    yield reset(dut)
    dut.enable <= 1
    yield logger(dut)

@cocotb.test()
def toggling_enable(dut):
    """ Test con enable variable de forma aleatoria"""

    cocotb.fork(Clock(dut.clk, 10, units='ns').start())
    yield reset(dut)
    cocotb.fork(logger(dut))

    rand = lambda:randint(0,1)

    for _ in range(2**int(dut.cnt.WIDTH)):
        value = rand()
        if dut.enable.value.integer != value:
            cocotb.log.info("[ enable ] enable <= %d" % value)
        dut.enable <= value
        yield RisingEdge(dut.clk)
        
        
        
    

