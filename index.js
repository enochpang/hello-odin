async function init() {
    const wasm_path = "./build/web.wasm";
    const wasm = await WebAssembly.instantiateStreaming(fetch(wasm_path));

    console.log(wasm.instance.exports.add(3,4));
    console.log(wasm);
}

init();