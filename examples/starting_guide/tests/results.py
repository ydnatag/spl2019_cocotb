import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ClockCycles, Event
from cocotb.clock import Clock
from cocotb.result import TestError, TestFailure, TestSuccess

@cocotb.test()
def test_failure(dut):
    yield Timer(1, units='ns')
    raise TestFailure("Mensaje descriptivo sobre la falla (failure)")

@cocotb.test()
def test_error(dut):
    yield Timer(1, units='ns')
    raise TestError("Mensaje descriptivo sobre el error (error)")

@cocotb.test()
def test_success(dut):
    yield Timer(1, units='ns')
    raise TestSuccess("Mensaje descriptivo sobre la condición de exito (success)")

@cocotb.test()
def test_exception(dut):
    yield Timer(1, units='ns')
    raise Exception("Mensaje descriptivo sobre el error (error)")

@cocotb.test()
def test_assert(dut):
    yield Timer(1, units='ns')
    assert 1 == 0
