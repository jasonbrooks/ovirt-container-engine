IMG=docker.io/fabiand/ovirt-engine-3.5:latest

build: Dockerfile
	docker build -t $(IMG) .

publish: build
	docker push $(IMG)

install:
	atomic install $(IMG)

uninstall:
	atomic uninstall $(IMG)
