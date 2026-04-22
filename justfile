[default]
build:
	odin build src -out:build/hello.exe

debug:
	odin build src -out:build/hello_debug.exe -debug

run: debug
	build/hello_debug.exe

check:
	odin check src -debug -vet -strict-style