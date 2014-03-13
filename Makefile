PROJECT_ROOT := $(shell pwd)
ifeq ($(shell pwd | xargs dirname | xargs basename),lib)
	VENDOR_PATH := $(shell pwd | xargs dirname | xargs dirname)/vendor
else
	VENDOR_PATH := $(PROJECT_ROOT)/vendor
endif

ifndef BASENAME
	BASENAME := "precise64"
endif

ifndef VERSION
	VERSION := "0.1.0"
endif

GOPATH := $(PROJECT_ROOT):$(VENDOR_PATH)
export GOPATH

all: build

build:
	@go build

deb: clean build
	@cp -a deb pkg
	@mkdir -p pkg/opt/atlantis/bin
	@mkdir -p pkg/opt/atlantis/builder

	@cp atlantis-mkbase pkg/opt/atlantis/bin/
	@cp atlantis-builder pkg/opt/atlantis/bin/

	@cp -a layers pkg/opt/atlantis/builder/
	@echo $(BASENAME) > pkg/opt/atlantis/builder/layers/basename.txt
	@echo $(VERSION) > pkg/opt/atlantis/builder/layers/version.txt

	@sed -ri "s/__VERSION__/$(VERSION)/" pkg/DEBIAN/control 
	@dpkg -b pkg .

fmt:
	@find . -name \*.go -exec go fmt {} \;

clean:
	@rm -rf atlantis-builder pkg *.deb
