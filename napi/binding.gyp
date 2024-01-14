{
    "targets": [
        {
            "target_name": "zig_core",
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


# {
#     "targets": [
#         {
#             "target_name": "zig_core",
#             "sources": ["src/native/c/zig_core.c", "src/native/c/napi_core.c"],
#             "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
#             "conditions": [
#                 [
#                     'OS=="mac"',
#                     {
#                         "libraries": [
#                             "<!(pwd)/src/build/macos/libvsfragment_cexports.a",
#                             "<!(pwd)/src/build/macos/libzignapi_ReleaseFast.a",
#                         ]
#                     },
#                 ],
#                 [
#                     'OS=="linux"',
#                     {
#                         "libraries": [  # we put compiled binaries in src/build/linux/arm
#                             "<!(pwd)/src/build/linux/arm/libvsfragment_cexports.a",
#                             "<!(pwd)/src/build/linux/arm/libzignapi_ReleaseFast.a",
#                         ]
#                     },
#                 ],
#             ],
#             "cflags!": ["-fno-exceptions"],
#             "cflags_cc!": ["-fno-exceptions"],
#         }
#     ]
# }
