{
    "targets": [
        {
            "target_name": "zig_core",
            "sources": ["src/zig_core.c", "src/napi_core.c"],  # Point to C source files
            "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
            "libraries": [  # Path to Zig-generated static libraries
                "/src/zig_fn/zig-out/native/libzignapi_fast.a",
                "/c_exports/zig-out/lib/native/libvsfragment_cexports_fast.a",
            ],
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-exceptions"],
        }
    ]
}
