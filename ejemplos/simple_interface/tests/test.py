import cocotb
from adderlib import SIMonitor, AdderSender, AdderReceiver
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from cocotb.result import TestFailure


@cocotb.coroutine
def reset(dut):
    dut.a <= 0
    dut.b <= 0
    dut.input_valid <= 0
    dut.output_ack <= 0
    dut.rst <= 1
    yield RisingEdge(dut.clk)
    dut.rst <= 0
    yield RisingEdge(dut.clk)

@cocotb.test()
def si_sumador(dut):
    data_range = 2**dut.WIDTH.value.integer

    sender = AdderSender(dut)
    receiver = AdderReceiver(dut)
    mon_a = SIMonitor(clk=dut.clk, data=dut.a, valid=dut.input_valid, ack=dut.input_ack)
    mon_b = SIMonitor(clk=dut.clk, data=dut.b, valid=dut.input_valid, ack=dut.input_ack)
    mon_sum = SIMonitor(clk=dut.clk, data=dut.sum, valid=dut.output_valid, ack=dut.output_ack)

    cocotb.fork(Clock(dut.clk, 10, units='ns').start())
    yield reset(dut)
    cocotb.fork(receiver.start())
    cocotb.fork(mon_a.start())
    cocotb.fork(mon_b.start())
    cocotb.fork(mon_sum.start())
    
    cr = cocotb.fork(sender.rand_send(n=30, max_latency=5))
    yield cr.join()
    
    for _ in range(10):
        yield RisingEdge(dut.clk)

    test_a = mon_a.get_buffer()
    test_b = mon_b.get_buffer()
    test_sum = mon_sum.get_buffer()

    expected_sum = [ (a + b) % data_range for a,b in zip(test_a, test_b)]

    if test_sum != expected_sum:
        raise TestFailure('sum != expected')
    

    
