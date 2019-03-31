import cocotb
from cocotb.triggers import Timer

## Acceso a señales. Escritura y lectura

@cocotb.test()
def write_read_signal(dut):
    rst = dut.rst.value  # Leo la señal
    cocotb.log.info("Iniciando el test: rst = {}".format(rst))

    dut.rst <= 0  # Seteo un valor
    rst = dut.rst.value # Que leo?
    cocotb.log.info("Antes del yield: rst = {}".format(rst))
    yield Timer(1, units='us')

    rst = dut.rst.value.integer
    cocotb.log.info("Despues del yield: rst = {}".format(rst))

@cocotb.test()
def hierarchical_access(dut):
    rst = dut.cnt.rst.value
    cocotb.log.info("dut.cnt.rst = {}".format(rst))

    rst = dut.rst.value
    cocotb.log.info("dut.rst = {}".format(rst))
    yield Timer(1, units='us')

@cocotb.test()
def signal_argument(dut):

    def write_signal(signal, value):
        signal <= value

    def read_signal(signal):
        return signal.value

    sig = dut.rst
    val = read_signal(sig)
    cocotb.log.info("Valor inicial de la señal: {}".format(val))
    write_signal(sig, 1)
    yield Timer(1, units='ns')
    val = read_signal(sig)
    cocotb.log.info("Valor Final de la señal: {}".format(val))
    
