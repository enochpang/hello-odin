build-wat: build
	wasm2wat build/web.wasm > build/web.wat

[default]
build:
	odin build src -out:build/web.wasm -target:js_wasm32 -no-entry-point -o:speed

check:
	odin check src -debug -vet -strict-style