all:
	hlsclt build syn
	cat sumador_hls/solution1/impl/verilog/sumador.v | \
	sed  's/endmodule.*//' > ../hdl/sumador.v
	cat dump.patch >> ../hdl/sumador.v

clean:
	hlsclt clean --yes
	rm c
