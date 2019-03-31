import cocotb
from cocotb.drivers.amba import AXI4LiteMaster
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge
from cocotb.result import ReturnValue

class SpiSlave(object):
    def __init__(self, spi_config, length):
        self.ss = spi_config['ss']
        self.sclk = spi_config['clk']
        self.mosi = spi_config['mosi']
        self.miso = spi_config['miso']
        self.slave = spi_config['slave']
        self.length = length
        self.monitor_buff = []
        cocotb.fork(self.monitor())
        cocotb.fork(self.loopback())

    @cocotb.coroutine
    def monitor(self):
        while True:
            data = 0
            yield FallingEdge(self.ss)
            for _ in range(self.length):
                yield RisingEdge(self. sclk)
                data = data << 1
                value = self.mosi.value.integer
                data |= value
            yield RisingEdge(self.ss)
            self.monitor_buff.append(data)

    @cocotb.coroutine
    def loopback(self):
        self.miso <= self.mosi.value
        while True:
            yield Edge(self.mosi)
            self.miso <= self.mosi.value

class SpiAxi (object):
    IDX_ID = 0<<2
    IDX_STATUS = 1<<2
    IDX_SLAVE = 2<<2
    IDX_LENGTH = 3<<2
    IDX_PRESCALER = 4<<2
    IDX_WRITE = 5<<2
    IDX_READ = 6<<2

    def __init__(self, dut, prefix):
        self.axi = AXI4LiteMaster(dut, prefix, dut.AXI_ACLK)
        self.clk = dut.AXI_ACLK
        self.irq = dut.INT

    @cocotb.coroutine
    def write(self, addr, value):
        yield self.axi.write(addr, value)

    @cocotb.coroutine
    def read(self, addr):
        value = yield self.axi.read(addr)
        raise ReturnValue(value)

    @cocotb.coroutine
    def send(self, value):
        yield self.write(self.IDX_WRITE, value)

    @cocotb.coroutine
    def recv(self):
        value = yield self.read(self.IDX_READ)
        raise ReturnValue(value)

    @cocotb.coroutine
    def wait_irq(self):
        if self.irq.value.integer == 0:
            yield RisingEdge(self.irq)

    @cocotb.coroutine
    def set_length(self, length):
        yield self.write(self.IDX_LENGTH, length)

    @cocotb.coroutine
    def get_length(self):
        value = yield self.read(self.IDX_LENGTH)
        raise ReturnValue(value)

    @cocotb.coroutine
    def set_prescaler(self, value):
        yield self.write(self.IDX_PRESCALER, value)

    @cocotb.coroutine
    def get_prescaler(self):
        value = yield self.read(self.IDX_PRESCALER)
        raise ReturnValue(value)

    @cocotb.coroutine
    def get_status(self):
        value = yield self.read(self.IDX_STATUS)
        raise ReturnValue(value)

    @cocotb.coroutine
    def set_slave(self, value):
        yield self.write(self.IDX_SLAVE, value)

    @cocotb.coroutine
    def get_slave(self):
        value = yield self.read(self.IDX_SLAVE)
        raise ReturnValue(value)

    @cocotb.coroutine
    def send_recv(self, data):
        yield RisingEdge(self.clk)
        yield self.send(data)
        yield self.wait_irq()
        read = yield self.recv()
        raise ReturnValue(read.integer)
