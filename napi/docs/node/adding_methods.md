# Creating a function in Zig exposed through C NAPI

- This is a function that accepts a `String` from Node - we need to define it with a `C` compatible type

```rust
export fn writeFile(file_path: [*c]const u8) u8 {
    const zig_file_path = std.mem.span(file_path);

    // Call writeToPath, which expects a Zig slice ([]const u8)
    return writeToPath(zig_file_path);
}
```

- Definition in `C` for `writeFile` func.


```c
extern uint8_t writeFile(const char *file_path);
```

- Defining the handling from Node calls in `c`

- Import `#include <stdlib.h>` to use `malloc`  and `free`  

```c
napi_value ZigWriteFile(napi_env env, napi_callback_info args)
{
  napi_status status;

  // make sure only 1 arg is passed from node call
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1)
  {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  // Get Size of String Passed (without reading the string)
  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  // Allocates memory for the string - including +1 for the null terminator
  char *file_path = malloc(str_size + 1);

  // Copy String from JS to Allocated Memory
  status = napi_get_value_string_utf8(
        env, argv[0], file_path, str_size + 1, &str_size_copied
      );
  
  if (status != napi_ok)
  {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  uint8_t result_from_zig = writeFile(file_path);
  free(file_path);

  // Get Result from Zig and send it back to JS
  
  napi_value js_result;
  status = napi_create_uint32(env, result_from_zig, &js_result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

```