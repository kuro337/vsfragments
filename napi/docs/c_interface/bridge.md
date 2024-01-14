# Adding new functions

- Write new function in Zig and mark it as `export`

```rust
export fn writeToDisk() u8 {
    return writeToDiskNoErr();
}
```

- Add the function to the `c` file that exports functions

```c
#include <node_api.h>
#include <stdio.h>

// existing funcs...
extern void writeToDisk();
```

- In `c` file that uses `napi` we need to add :
  - `napi_value` block for the new Function
  - Register the function in `napi Init` Block

Create a new `napi_value` block

```c
extern void writeToDisk();

// Node-API wrapper for the Zig 'add' function
napi_value ZigAdd(napi_env env, napi_callback_info args)
{
  napi_status status;
  size_t argc = 2;
  //  ...
  //  ...
  //  ...
}
```

- Template for creating `napi_value` for new Functions

```c
// ADD A NAPI_VALUE WITH FUNCTION DEF AND JS RETURN

napi_value YourFunctionWrapper(napi_env env, napi_callback_info args) {
    // Extract arguments from 'args' if needed
    // Your argument extraction logic here...

    // Call the actual function (C, C++, or Zig, etc.)
    FuncReturnType_C function_result = YourActualFunction(arguments_if_any);

    // Convert the result to a JavaScript value
    napi_value js_result;
    // Use appropriate napi_create_* function based on the return type
    //napi_status status = napi_create_appropriate_type(env, function_result, &js_result);

    // ex our Zig func returns u8 but it needs to be uint32_t
    napi_status status = napi_create_uint32(env, (uint32_t)result_from_zig, &js_result);

    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    }

    return js_result;
}


// NODE_API WRAPPER => writeToDisk()
napi_value ZigWriteDisk(napi_env env, napi_callback_info args)
{
  // Call the Zig function
  uint8_t result_from_zig = writeToDisk();

  // Create a JavaScript number to return
  napi_value js_result;
  napi_status status = napi_create_uint32(env, (uint32_t)result_from_zig, &js_result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
  }

  return js_result;
}

// Init Block

// Function to initialize the addon
napi_value Init(napi_env env, napi_value exports)
{
  napi_status status;
  napi_value fn;
//
//
//
  // Register the 'ZigWriteDisk' function
  status = napi_create_function(env, NULL, 0, ZigWriteDisk, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for writeToDisk");
  }
  status = napi_set_named_property(env, exports, "writeToDisk", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for writeToDisk");
  }

  return exports;
}
```

- Make sure `zig` func is built `zig build-lib funcs.zig -static`

  - `funcs.zig` turns into `libfuncs.a`

- Make sure `binding.gyp` has the correct paths

```py
{
    "targets": [
        {
            "target_name": "fromzig",
            "sources": ["src/from_zig.c"],  # Point to C source files
            "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
            "libraries": [
                "/Users/kuro/Documents/Code/JS/FFI/zig_c_napi/ffi/src/zig_fn/libfuncs.a"
            ],  # Path to Zig-generated static library
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-exceptions"],
        }
    ]
}
```

- Add new func to `index.js`

```js
const myAddon = require("./build/Release/addon");
myAddon.writeToDisk();
```

- Build and Run
-

```bash
npm install
node index.js
```
