
build: Dockerfile
	docker build -t docker.io/fabiand/engine:latest .

d.%: build
	$(shell sed -n "/LABEL $* docker/ s/LABEL $*// p" Dockerfile)
