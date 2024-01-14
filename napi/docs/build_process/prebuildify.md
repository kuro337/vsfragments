# Prebuildify

- Creates cached built packages so users do not need to recompile the native packages.

- Works in combination with **node-gyp-build**

```bash
# create prebuilt package in folder lib/

prebuildify --napi --out lib

# to prebuild for linux arm

prebuildify --napi --platform=linux --arch=arm64 --out lib

# Create prebuilds folder in lib/macos14/prebuilds/
# note:relies on it being set in binding.gyp

prebuildify --napi --tag "macos14" --out lib/macos14
prebuildify --napi --tag "macos11" --out lib/macos11/

# need to run it after creating the proper binaries from that env obviously
prebuildify --napi --platform=linux --arch=arm64 --out lib

```

- Creating binaries for MacOS

```bash
{
    "targets": [
        {
            "target_name": "zig_core",
            "xcode_settings": {"MACOSX_DEPLOYMENT_TARGET": "14.1.2"},
            "sources": [  # Point to C source files
                "src/native/c/zig_core.c",
                "src/native/c/napi_core.c",
            ],
            "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
            "libraries": [  # zig static library build artifacts
                "<!(pwd)/src/build/libvsfragment_cexports.a",
                "<!(pwd)/src/build/libzignapi_ReleaseFast.a",
            ],
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-exceptions"],
        }
    ]
}

```
