#include "napi_core.h"
#include <node_api.h>
#include <stdio.h>
#include <stdlib.h>

extern int add(int a, int b);

extern uint8_t writeFileCurrPath(const char *file_path);
extern uint8_t writeFileToPathAbs(const char *file_path);

extern const char *getPath(const char *file_path);

// Node-API wrapper for the Zig 'add' function
napi_value ZigAdd(napi_env env, napi_callback_info args) {
  napi_status status;
  size_t argc = 2;
  napi_value argv[2];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Failed to parse arguments");
  }

  int value1, value2;
  status = napi_get_value_int32(env, argv[0], &value1);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Invalid number as first argument");
  }

  status = napi_get_value_int32(env, argv[1], &value2);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Invalid number as second argument");
  }

  int result = add(value1, value2);
  napi_value sum;
  status = napi_create_int32(env, result, &sum);

  return sum;
}

// NODE_API WRAPPER => writeFileCurrPathCurrPath()
napi_value ZigWriteFileCurrPath(napi_env env, napi_callback_info args) {
  napi_status status;
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1) {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  char *file_path = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], file_path, str_size + 1,
                                      &str_size_copied);
  if (status != napi_ok) {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  uint8_t result_from_zig = writeFileCurrPath(file_path);
  free(file_path);

  napi_value js_result;
  status = napi_create_uint32(env, result_from_zig, &js_result);

  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// NODE_API WRAPPER => writeFileToPathAbs()
napi_value ZigWriteFileToPathAbs(napi_env env, napi_callback_info args) {
  napi_status status;
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1) {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  char *file_path = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], file_path, str_size + 1,
                                      &str_size_copied);
  if (status != napi_ok) {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  uint8_t result_from_zig = writeFileToPathAbs(file_path);
  free(file_path);

  napi_value js_result;
  status = napi_create_uint32(env, result_from_zig, &js_result);

  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// NODE_API WRAPPER => getPath()
napi_value ZigGetPath(napi_env env, napi_callback_info args) {
  napi_status status;
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1) {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  char *file_path = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], file_path, str_size + 1,
                                      &str_size_copied);
  if (status != napi_ok) {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  const char *result_from_zig = getPath(file_path);
  free(file_path); // Free the file_path after use

  napi_value js_result;
  status = napi_create_string_utf8(env, result_from_zig, NAPI_AUTO_LENGTH,
                                   &js_result);

  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// ================= REGISTRATION

// Function to abstract the process of registering a Node-API function
napi_status register_napi_function(napi_env env, napi_value exports,
                                   const char *export_name,
                                   napi_callback callback) {
  napi_status status;
  napi_value fn;

  status = napi_create_function(env, NULL, 0, callback, NULL, &fn);
  if (status != napi_ok) {
    return status;
  }

  status = napi_set_named_property(env, exports, export_name, fn);
  return status;
}

napi_value Init(napi_env env, napi_value exports) {
  napi_status status;

  status = register_napi_function(env, exports, "zigAdd", ZigAdd);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Unable to register function for zigAdd");
  }

  status = register_napi_function(env, exports, "writeFileCurrPathCurrPath",
                                  ZigWriteFileCurrPath);
  if (status != napi_ok) {
    napi_throw_error(
        env, NULL, "Unable to register function for writeFileCurrPathCurrPath");
  }

  status = register_napi_function(env, exports, "writeFileToPathAbs",
                                  ZigWriteFileToPathAbs);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for writeFileToPathAbs");
  }
  status = register_napi_function(env, exports, "getPath", ZigGetPath);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Unable to register function for getPath");
  }

  // ZIG_CORE

  status = register_napi_function(env, exports, "receiveStringFromJS",
                                  receiveStringFromJS);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for receiveStringFromJS");
  }

  status = register_napi_function(env, exports, "parseStringFromNode",
                                  ZigparseStringFromNode);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for parseStringFromNode");
  }

  status = register_napi_function(env, exports, "parseFileGetSnippet",
                                  ZigParseFileGetSnippet);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for parseFileGetSnippet");
  }

  status = register_napi_function(env, exports, "createSnippetWithMetadata",
                                  ZigCreateSnippetWithMetadata);
  if (status != napi_ok) {
    napi_throw_error(
        env, NULL, "Unable to register function for createSnippetWithMetadata");
  }

  status = register_napi_function(env, exports, "convertDirToSnippet",
                                  ZigConvertDirToSnippet);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for convertDirToSnippet");
  }

  status = register_napi_function(env, exports, "parseFileWriteOutput",
                                  ZigParseFileWriteOutput);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for parseFileWriteOutput");
  }

  status = register_napi_function(env, exports, "parseStringWriteToFile",
                                  ZigParseStringWriteToFile);
  if (status != napi_ok) {
    napi_throw_error(env, NULL,
                     "Unable to register function for parseStringWriteToFile");
  }

  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
