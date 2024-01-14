# node-gyp

- Node gyp

https://github.com/nodejs/node-gyp

```bash
Creates Node Package from Native Static Library Binaries we create

Uses binding.gyp

# example usage

node-gyp configure
node-gyp build

```

```py
{
    "targets": [
        {
            "target_name": "zig_core",
            "sources": ["src/native/c/zig_core.c", "src/native/c/napi_core.c"],
            "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
            "conditions": [
                [
                    'OS=="mac"',
                    {
                        "libraries": [
                            "<!(pwd)/src/build/macos/libvsfragment_cexports.a",
                            "<!(pwd)/src/build/macos/libzignapi_ReleaseFast.a",
                        ]
                    },
                ],
                [
                    'OS=="linux"',
                    {
                        "libraries": [  # we put compiled binaries in src/build/linux/arm
                            "<!(pwd)/src/build/linux/arm/libvsfragment_cexports.a",
                            "<!(pwd)/src/build/linux/arm/libzignapi_ReleaseFast.a",
                        ]
                    },
                ],
            ],
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-exceptions"],
        }
    ]
}

```

- For Linux Binaries use

```bash

# This command updates the index to the archive, making it usable for linking.

ranlib src/build/linux/arm/libvsfragment_cexports.a
ranlib src/build/linux/arm/libzignapi_ReleaseFast.a


```
