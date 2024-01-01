#include <node_api.h>
#include <stdio.h>
#include <stdlib.h>    // to use for malloc and free
#include "napi_core.h" // import func

// Declare the Zig function definitions
extern int add(int a, int b);
extern const char *getString();

extern u_int8_t testWriteSampleFile();
extern uint8_t writeFileCurrPath(const char *file_path);
extern uint8_t writeFileToPathAbs(const char *file_path);

extern const char *getPath(const char *file_path); // Declare the new function

// Node-API wrapper for the Zig 'add' function
napi_value ZigAdd(napi_env env, napi_callback_info args)
{
  napi_status status;
  size_t argc = 2;
  napi_value argv[2];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Failed to parse arguments");
  }

  int value1, value2;
  status = napi_get_value_int32(env, argv[0], &value1);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Invalid number as first argument");
  }

  status = napi_get_value_int32(env, argv[1], &value2);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Invalid number as second argument");
  }

  int result = add(value1, value2);
  napi_value sum;
  status = napi_create_int32(env, result, &sum);

  return sum;
}

// NODE_API WRAPPER => getString()
napi_value ZigGetString(napi_env env, napi_callback_info args)
{
  const char *str = getString();
  napi_value result;
  napi_status status = napi_create_string_utf8(env, str, NAPI_AUTO_LENGTH, &result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create Wrapper for Zig Create String");
  }

  return result;
}

// NODE_API WRAPPER => testWriteSampleFile()
napi_value ZigTestWrite(napi_env env, napi_callback_info args)
{
  // Call the Zig function
  uint8_t result_from_zig = testWriteSampleFile();

  // Create a JavaScript number to return
  napi_value js_result;
  napi_status status = napi_create_uint32(env, (uint32_t)result_from_zig, &js_result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
  }

  return js_result;
}

// NODE_API WRAPPER => writeFileCurrPathCurrPath()
napi_value ZigWriteFileCurrPath(napi_env env, napi_callback_info args)
{
  napi_status status;
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1)
  {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  char *file_path = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], file_path, str_size + 1, &str_size_copied);
  if (status != napi_ok)
  {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  uint8_t result_from_zig = writeFileCurrPath(file_path);
  free(file_path);

  napi_value js_result;
  status = napi_create_uint32(env, result_from_zig, &js_result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// NODE_API WRAPPER => writeFileToPathAbs()
napi_value ZigWriteFileToPathAbs(napi_env env, napi_callback_info args)
{
  napi_status status;
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1)
  {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  char *file_path = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], file_path, str_size + 1, &str_size_copied);
  if (status != napi_ok)
  {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  uint8_t result_from_zig = writeFileToPathAbs(file_path);
  free(file_path);

  napi_value js_result;
  status = napi_create_uint32(env, result_from_zig, &js_result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// NODE_API WRAPPER => getPath()
napi_value ZigGetPath(napi_env env, napi_callback_info args)
{
  napi_status status;
  size_t argc = 1;
  napi_value argv[1];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 1)
  {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  size_t str_size;
  size_t str_size_copied;
  status = napi_get_value_string_utf8(env, argv[0], NULL, 0, &str_size);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Failed to get string size");
    return NULL;
  }

  char *file_path = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], file_path, str_size + 1, &str_size_copied);
  if (status != napi_ok)
  {
    free(file_path);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  const char *result_from_zig = getPath(file_path);
  free(file_path); // Free the file_path after use

  napi_value js_result;
  status = napi_create_string_utf8(env, result_from_zig, NAPI_AUTO_LENGTH, &js_result);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// Function to initialize the addon
napi_value Init(napi_env env, napi_value exports)
{
  napi_status status;
  napi_value fn;

  // Register the 'ZigAdd' function
  status = napi_create_function(env, NULL, 0, ZigAdd, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for Zig add");
  }
  status = napi_set_named_property(env, exports, "zigAdd", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for Zig add");
  }

  // Register the 'ZigGetString' function
  status = napi_create_function(env, NULL, 0, ZigGetString, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for getString");
  }
  status = napi_set_named_property(env, exports, "getString", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for getString");
  }

  // Register the 'ZigTestWrite' function
  status = napi_create_function(env, NULL, 0, ZigTestWrite, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for testWriteSampleFile");
  }
  status = napi_set_named_property(env, exports, "testWriteSampleFile", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for testWriteSampleFile");
  }

  // Register the 'ZigWriteFileCurrPath' function
  status = napi_create_function(env, NULL, 0, ZigWriteFileCurrPath, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for writeFile");
    return NULL;
  }
  status = napi_set_named_property(env, exports, "writeFileCurrPath", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for writeFileCurrPath");
    return NULL;
  }

  // Register the 'ZigWriteFileToPathAbs' function
  status = napi_create_function(env, NULL, 0, ZigWriteFileToPathAbs, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for writeFile");
    return NULL;
  }
  status = napi_set_named_property(env, exports, "writeFileToPathAbs", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for writeFileToPathAbs");
    return NULL;
  }

  // Register the 'ZigGetPath' function
  status = napi_create_function(env, NULL, 0, ZigGetPath, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for getPath");
    return NULL;
  }
  status = napi_set_named_property(env, exports, "getPath", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for getPath");
    return NULL;
  }

  // Register the 'ZigParseFileGetSnippet' function
  status = napi_create_function(env, NULL, 0, ZigParseFileGetSnippet, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for parseFileGetSnippet");
    return NULL;
  }
  status = napi_set_named_property(env, exports, "parseFileGetSnippet", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for parseFileGetSnippet");
    return NULL;
  }

  // Register the 'receiveStringFromJS' function (imported in header file from_js.h)
  status = napi_create_function(env, NULL, 0, receiveStringFromJS, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for receiveStringFromJS");
    return NULL;
  }
  status = napi_set_named_property(env, exports, "receiveStringFromJS", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for receiveStringFromJS");
    return NULL;
  }

  // Register the 'ZigParseStringFromJS' function (imported in header file from_js.h)
  status = napi_create_function(env, NULL, 0, ZigParseStringFromJS, NULL, &fn);
  if (status != napi_ok)
    return NULL;

  // Set the named property
  status = napi_set_named_property(env, exports, "parseStringFromJS", fn);
  if (status != napi_ok)
    return NULL;

  // Register the 'ZigCreateSnippetWithMetadata' function
  status = napi_create_function(env, NULL, 0, ZigCreateSnippetWithMetadata, NULL, &fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function for createSnippetWithMetadata");
    return NULL;
  }
  status = napi_set_named_property(env, exports, "createSnippetWithMetadata", fn);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports for createSnippetWithMetadata");
    return NULL;
  }

  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
