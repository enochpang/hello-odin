web-wat: web-wasm
	wasm2wat build/web.wasm > build/web.wat

[default]
web-wasm:
	odin build src -out:build/web.wasm -target:js_wasm32 -no-entry-point -o:speed