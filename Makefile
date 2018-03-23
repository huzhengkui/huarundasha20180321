# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gplc android ios gplc-cross swarm evm all test clean
.PHONY: gplc-linux gplc-linux-386 gplc-linux-amd64 gplc-linux-mips64 gplc-linux-mips64le
.PHONY: gplc-linux-arm gplc-linux-arm-5 gplc-linux-arm-6 gplc-linux-arm-7 gplc-linux-arm64
.PHONY: gplc-darwin gplc-darwin-386 gplc-darwin-amd64
.PHONY: gplc-windows gplc-windows-386 gplc-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gplc:
	build/env.sh go run build/ci.go install ./cmd/gplc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gplc\" to launch gplc."

swarm:
	build/env.sh go run build/ci.go install ./cmd/swarm
	@echo "Done building."
	@echo "Run \"$(GOBIN)/swarm\" to launch swarm."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gplc.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gplc.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

clean:
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gplc-cross: gplc-linux gplc-darwin gplc-windows gplc-android gplc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gplc-*

gplc-linux: gplc-linux-386 gplc-linux-amd64 gplc-linux-arm gplc-linux-mips64 gplc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-*

gplc-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gplc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep 386

gplc-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gplc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep amd64

gplc-linux-arm: gplc-linux-arm-5 gplc-linux-arm-6 gplc-linux-arm-7 gplc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep arm

gplc-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gplc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep arm-5

gplc-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gplc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep arm-6

gplc-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gplc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep arm-7

gplc-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gplc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep arm64

gplc-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gplc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep mips

gplc-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gplc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep mipsle

gplc-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gplc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep mips64

gplc-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gplc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gplc-linux-* | grep mips64le

gplc-darwin: gplc-darwin-386 gplc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gplc-darwin-*

gplc-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gplc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-darwin-* | grep 386

gplc-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gplc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-darwin-* | grep amd64

gplc-windows: gplc-windows-386 gplc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gplc-windows-*

gplc-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gplc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-windows-* | grep 386

gplc-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gplc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gplc-windows-* | grep amd64
