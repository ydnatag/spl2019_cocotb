import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ClockCycles, Event
from cocotb.clock import Clock
from cocotb.result import TestError, TestFailure, TestSuccess

@cocotb.test()
def fork_coroutines(dut):
    """ Lanza una corutina en paralelo """

    @cocotb.coroutine
    def print_coroutine():
        time = 0
        for _ in range(10):
            cocotb.log.info('[ print_coroutine ] %d ns' % time)
            yield Timer(250, units='ns')
            time += 250

    # print_coroutine se ejecuta en "paralelo"
    cocotb.fork(print_coroutine())
    time = 0
    for _ in range(6):
        cocotb.log.info('[ test ] %d us' % time)
        yield Timer(1, units='us')
        time += 1

@cocotb.test()
def fork_clock(dut):
    """ Generador de clock """

    # Lanzo el generador de clock
    cocotb.fork(Clock(dut.clk, 10, units='ns').start())

    dut.rst <= 1
    # Espero 5 ciclos de clock (Espera 4... posible bug?)
    yield ClockCycles(dut.clk, 5)
    dut.rst <= 0

    # Espero otros 5 ciclos de clock
    for _ in range(5):
        yield RisingEdge(dut.clk)


@cocotb.test()
def join_coroutines(dut):
    """ Esperar finalización de corutina """

    @cocotb.coroutine
    def print_coroutine():
        time = 0
        for _ in range(10):
            cocotb.log.info('[ print_coroutine ] %d ns' % time)
            yield Timer(250, units='ns')
            time += 250

    # Lanzo una corutina
    print_co = cocotb.fork(print_coroutine())
    cocotb.log.info("waiting coroutine")

    # Espero que termine
    yield print_co.join()
    cocotb.log.info("Coroutine finished")



@cocotb.test()
def coroutine_sync(dut):
    """ Syncronización de corutinas """

    @cocotb.coroutine
    def coroutine_a(e):
        cocotb.log.info('coroutine a start')
        yield Timer(100, units='us')
        cocotb.log.info('coroutine a finished')
        e.set()

    @cocotb.coroutine
    def coroutine_b(e):
        cocotb.log.info('coroutine b start')
        yield e.wait()
        cocotb.log.info('coroutine b received event')
        yield Timer(100, units='us')
        cocotb.log.info('coroutine a finished')

    event = Event()

    # Lanzo corutina A
    a_co = cocotb.fork(coroutine_a(event))

    # Lanzo al mismo tiempo la corutina B
    # que depende de A
    b_co = cocotb.fork(coroutine_b(event))

    # Espero que termine B
    yield b_co.join()

 

   
