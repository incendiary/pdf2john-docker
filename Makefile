.PHONY: build test

IMAGE ?= pdf2john

build:
	docker build -t $(IMAGE) .

test: build
	@chmod +x tests/test_extraction.sh tests/test_non_pdf.sh
	@bash tests/test_extraction.sh
	@bash tests/test_non_pdf.sh
