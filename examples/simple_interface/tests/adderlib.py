import cocotb
from cocotb.triggers import RisingEdge, Edge
from cocotb.clock import Clock
from random import randint

class SIMonitor():
    def __init__(self, clk, data, valid, ack):
        self.clk = clk
        self.data = data
        self.valid = valid
        self.ack = ack
        self.buffer = []

    @cocotb.coroutine
    def monitor(self):
        r_e = RisingEdge(self.clk)
        while True:
            valid = self.valid.value.integer
            ack = self.ack.value.integer
            if valid == 1 and ack == 1:
                data = self.data.value.integer
                self.buffer.append(data)
            yield r_e

    @cocotb.coroutine
    def start(self):
        yield self.monitor()
        
    def clear(self):
        self.buffer = []

    def get_buffer(self):
        return list(self.buffer)


class AdderSender():
    def __init__(self, dut):
        self.clk = dut.clk
        self.a = dut.a
        self.b = dut.b
        self.valid = dut.input_valid
        self.ack = dut.input_ack
        self.range = 2**dut.WIDTH.value.integer - 1

    @cocotb.coroutine
    def rand_send(self, n=10, max_latency=0):
        r_e = RisingEdge(self.clk)
        self.valid <= 0
        for _ in range(n):
            for _ in range(randint(0, max_latency)):
                yield r_e
            self.valid <= 1
            self.a <= randint(0,self.range)
            self.b <= randint(0,self.range)
            yield r_e
            while self.ack.value.integer != 1:
                yield r_e
            self.valid <= 0
        
class AdderReceiver():
    def __init__(self, dut):
        self.clk = dut.clk
        self.sum = dut.sum
        self.valid = dut.output_valid
        self.ack = dut.output_ack
        self.ack_rand_latency = 2

    @cocotb.coroutine
    def start(self):
        r_e = RisingEdge(self.clk)
        valid_edge = Edge(self.valid)
        while True:
                yield [valid_edge, r_e]
                self.ack <= 0
                if self.valid.value.integer == 1:
                    for i in range(randint(0,self.ack_rand_latency)):
                        yield r_e
                    if self.valid.value.integer == 1:
                        self.ack <= 1
