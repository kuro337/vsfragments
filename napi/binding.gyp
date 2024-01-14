{
    "targets": [
        {
            "target_name": "vsfragments_node",
            # "xcode_settings": {"MACOSX_DEPLOYMENT_TARGET": "11.0"},
            "sources": [  # Point to C source files
                "src/native/zig_core.c",
                "src/native/napi_core.c",
            ],
            "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
            "libraries": [  # zig static library build artifacts
                "<!(pwd)/static/lib/libparse_file_c.a",
                "<!(pwd)/static/lib/libutils.a",
            ],
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-exceptions"],
        }
    ]
}
