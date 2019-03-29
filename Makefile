
cocotest:
	make -C examples/cocotest/

page:
	utils/build_page.sh

clean:
	make -C examples/cocotest/ clean
	make -C examples/starting_guide/ clean

