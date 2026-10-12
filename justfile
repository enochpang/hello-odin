[default]
build:
	odin build src -out:build/hello_debug.exe -debug

run: build
	build/hello_debug.exe

release:
	odin build src -out:build/hello.exe

check:
	odin check src -debug -vet -strict-style