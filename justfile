run: build
	build/hello.exe

[default]
build:
	odin build src -out:build/hello.exe