from python:3.7

RUN apt update && apt install -y iverilog gtkwave make clang llvm \
                                 build-essential zlib1g-dev git gnat

WORKDIR /root

RUN git clone https://github.com/tgingold/ghdl.git ghdl_src/ \
    && cd ghdl_src \
    && ./configure --prefix=/usr/local --with-llvm-config \
    && make \
    && make install \
    && make clean \
    && cd .. \
    && rm -r ./ghdl_src --force


RUN pip install git+https://github.com/potentialventures/cocotb.git

