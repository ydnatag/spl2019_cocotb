import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge
from cocotb.result import TestFailure, TestError, ReturnValue, SimFailure, TestSuccess
from cocotb.utils import get_sim_time
from spi import SpiAxi, SpiSlave

CLK_PERIOD = 10 # ns

@cocotb.coroutine
def reset(dut):
    dut.AXI_ARESETN <=  0
    yield Timer(CLK_PERIOD * 10, units='ns')
    dut.AXI_ARESETN  <= 1
    yield Timer(CLK_PERIOD * 10, units='ns')
    yield RisingEdge(dut.AXI_ACLK)

@cocotb.coroutine
def init_spi(dut, length, prescaler, slave=1):
    spi_config = {'ss': dut.SS,
                   'clk': dut.SCLK,
                   'miso': dut.MISO,
                   'mosi': dut.MOSI,
                   'slave': slave }

    yield RisingEdge(dut.AXI_ACLK)
    spi_axi = SpiAxi(dut, prefix='AXI')
    spi_slave = SpiSlave(spi_config, length)
    yield spi_axi.set_slave(slave)
    yield spi_axi.set_prescaler(prescaler)
    yield spi_axi.set_length(length)

    return (spi_axi, spi_slave)

@cocotb.test()
def loopback_test(dut):
    """ Estan conectados mosi y miso. Lo que se envia se deberia recibir"""

    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield reset(dut)
    spi_axi, spi_slave = yield init_spi(dut, 8, 10)
    pass


@cocotb.test()
def variable_length(dut):
    """ Probar el dispositivo para distintos largos de palabra"""

    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield reset(dut)

    for i in [8, 10, 27, 32]:
        spi_axi, spi_slave = yield init_spi(dut, length=i, prescaler=10)
        pass

@cocotb.test()
def spi_freq_test(dut):
    """ Medir la frecuencia del spi para distintos prescalers"""

    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield reset(dut)

    prescaler = 10
    spi_axi, spi_slave = yield init_spi(dut, 8, prescaler)

    yield spi_axi.send(0xAA)

    # Utilizar la función get_sim_time
    # t = get_sim_time(units='ns')


@cocotb.test()
def endianness_test(dut):
    """ Corroborar el endianness """
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield reset(dut)
    spi_axi, spi_slave = yield init_spi(dut, 8, 10)



@cocotb.test()
def sequence_test(dut):
    """ Chequear que la secuencia sea:
        - Flanco de SS
        - Length flancos ascendentes del SCLK
        - Flanco de SS
    """
    cocotb.fork(Clock(dut.AXI_ACLK, period=CLK_PERIOD, units='ns').start())
    yield reset(dut)
    spi_axi, spi_slave = yield init_spi(dut, 8, 10)
    send = cocotb.fork(spi_axi.send_recv(0x55))

    ss = Edge(dut.SS)
    r_sclk = RisingEdge(dut.SCLK)
    timeout = Timer(150, units='us')

    yield  send.join()






