
REPO_PATH:=$(shell git rev-parse --show-toplevel)

COCO_IMG=andresdemski/spl2019:cocotb
PRES_IMG=andresdemski/spl2019:revealmd

cocotest:
	make -C ejemplos/cocotest/
	make -C ejemplos/starting_guide/
	make -C ejemplos/simple_interface/

build_images:
	docker build -f .docker/Dockerfile -t $(COCO_IMG) .
	docker build -f .docker/Dockerfile.presentacion -t $(PRES_IMG) .

clean:
	make -C ejemplos/cocotest/ clean
	make -C ejemplos/starting_guide/ clean
	make -C ejemplos/simple_interface/ clean
	rm -rf presentation/static

