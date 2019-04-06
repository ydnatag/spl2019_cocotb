from python:3.6

RUN apt update && apt install -y  --no-install-recommends iverilog gtkwave make build-essential git gnat

WORKDIR /root

RUN git clone https://github.com/tgingold/ghdl.git ghdl_src/ \
    && cd ghdl_src \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && make clean \
    && cd .. \
    && rm -r ./ghdl_src --force


RUN pip install git+https://github.com/potentialventures/cocotb.git

CMD /bin/bash

