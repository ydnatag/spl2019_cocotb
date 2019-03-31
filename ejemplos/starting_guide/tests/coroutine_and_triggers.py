import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ClockCycles, Event
from cocotb.clock import Clock
from cocotb.result import TestError, TestFailure, TestSuccess

@cocotb.test()
def call_coroutines(dut):

    @cocotb.coroutine
    def reset(dut):
        dut.rst <= 1
        dut.enable <= 0
        dut.clk <= 0
        yield Timer(1, units='us')
        dut.clk <= 0
    
    # Consumo de tiempo, mueve el port de reset
    yield reset(dut)


@cocotb.test()
def call_coroutines(dut):

    @cocotb.coroutine
    def wait_and_read(dut):
        yield Timer(1, units='us')
        r = dut.rst.value
        return r

    dut.rst <= 1
    
    # Corutina que retorna un valor
    r = yield wait_and_read(dut)

    cocotb.log.info("readead value: rv = {}".format(r))
    

@cocotb.test()
def triggers(dut):

    # Creo el clock
    clk = cocotb.fork(Clock(dut.clk, 10, units='ns').start())
    
    # Espero 1us
    yield Timer(1, units='us')
    cocotb.log.info('Timer 1: pass')

    # Espero 1 flanco ascendente
    yield RisingEdge(dut.clk)
    cocotb.log.info('RisingEdge: pass')

    # Detengo el clock
    clk.kill()

    # Preparo un timeout
    timeout = Timer(1, units='us')
    
    # Espero un flanco ascendente pero con timeout
    trg = yield [RisingEdge(dut.clk), timeout]

    if trg == timeout:
        cocotb.log.info('Timeout: pass')
    else:
        cocotb.log.info('Timeout: fail')
    
    

