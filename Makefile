
cocotest:
	make -C ejemplos/cocotest/
	make -C ejemplos/starting_guide/
	make -C ejemplos/simple_interface/

page:
	utils/build_page.sh

clean:
	make -C ejemplos/cocotest/ clean
	make -C ejemplos/starting_guide/ clean
	make -C ejemplos/simple_interface/ clean

