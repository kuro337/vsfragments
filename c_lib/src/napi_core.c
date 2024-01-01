#include <node_api.h>
#include <stdio.h>
#include <stdlib.h>

extern void processStringFromCJS(const char *str);

extern const char *parseSnippetFromString(const char *str);

extern const char *parseFileGetSnippet(const char *file_path, bool print_out);

extern const char *createSnippetWithMetadata(const char *file_path, const char *title, const char *prefix, const char *description, bool new_snippet_file, bool print_out);

/*
==================================================
HELPERS TO EXTRACT ARGUMENTS
==================================================
*/

// Helper function to extract a string from a JavaScript value

char *
extractStringArg(napi_env env, napi_value arg)
{
  size_t str_size;
  napi_status status = napi_get_value_string_utf8(env, arg, NULL, 0, &str_size);
  if (status != napi_ok)
  {
    return NULL;
  }

  char *str = malloc(str_size + 1);
  if (str == NULL)
  {
    return NULL;
  }

  status = napi_get_value_string_utf8(env, arg, str, str_size + 1, NULL);
  if (status != napi_ok)
  {
    free(str);
    return NULL;
  }

  return str;
}

// Helper function to extract a boolean from a JavaScript value

bool extractBoolArg(napi_env env, napi_value arg)
{
  bool value;
  napi_status status = napi_get_value_bool(env, arg, &value);
  if (status != napi_ok)
  {
    // Handle error appropriately
  }
  return value;
}

/*
==============================================================
NAPI FUNCTIONS: Extract Args from Node & Use Zig Exported Functions
==============================================================
*/

// Node-API wrapper for the 'receiveStringFromJS' function
napi_value receiveStringFromJS(napi_env env, napi_callback_info args)
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

  char *input_str = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], input_str, str_size + 1, &str_size_copied);
  if (status != napi_ok)
  {
    free(input_str);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  // Log the string received from JavaScript
  printf("Received string from JavaScript: %s\n", input_str);

  // Call the Zig function
  processStringFromCJS(input_str);

  free(input_str);

  // Create a JavaScript number to return as success
  napi_value js_result;
  status = napi_create_uint32(env, 0, &js_result); // 0 indicates success

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript return value");
    return NULL;
  }

  return js_result;
}

// ==================================================
// Node-API wrapper for the 'parseStringFromJS' function

napi_value ZigParseStringFromJS(napi_env env, napi_callback_info args)
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

  char *input_str = malloc(str_size + 1);
  status = napi_get_value_string_utf8(env, argv[0], input_str, str_size + 1, &str_size_copied);
  if (status != napi_ok)
  {
    free(input_str);
    napi_throw_error(env, NULL, "Failed to get string value");
    return NULL;
  }

  const char *parsed_str = parseSnippetFromString(input_str); // Get string from Zig
  free(input_str);                                            // Free the original input string

  // Create a JavaScript string from the returned Zig string
  napi_value js_result;
  status = napi_create_string_utf8(env, parsed_str, NAPI_AUTO_LENGTH, &js_result);

  // IMPORTANT: Free the parsed string ONLY if it's dynamically allocated in Zig
  free(parsed_str);

  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create JavaScript string");
    return NULL;
  }

  return js_result;
}

// ==================================================
// NODE_API WRAPPER => parseFileGetSnippet()

napi_value ZigParseFileGetSnippet(napi_env env, napi_callback_info args)
{
  napi_status status;
  size_t argc = 2;
  napi_value argv[2];
  status = napi_get_cb_info(env, args, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 2)
  {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  // Get the file path string
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

  // Get the print_out flag
  bool print_out;
  status = napi_get_value_bool(env, argv[1], &print_out);
  if (status != napi_ok)
  {
    free(file_path);
    napi_throw_error(env, NULL, "Invalid print_out flag argument");
    return NULL;
  }

  // Call the Zig function
  const char *result_from_zig = parseFileGetSnippet(file_path, print_out);
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

// ==================================================
// NODE_API WRAPPER => createSnippetWithMetadata()

napi_value ZigCreateSnippetWithMetadata(napi_env env, napi_callback_info info)
{
  napi_status status;
  size_t argc = 6;
  napi_value argv[6];
  status = napi_get_cb_info(env, info, &argc, argv, NULL, NULL);

  if (status != napi_ok || argc != 6)
  {
    napi_throw_error(env, NULL, "Invalid number of arguments");
    return NULL;
  }

  // Extract string arguments and boolean flag
  char *file_path = extractStringArg(env, argv[0]);
  char *title = extractStringArg(env, argv[1]);
  char *prefix = extractStringArg(env, argv[2]);
  char *description = extractStringArg(env, argv[3]);
  bool new_snippet_file = extractBoolArg(env, argv[4]);
  bool print_out = extractBoolArg(env, argv[5]);

  // Call the Zig function
  const char *result = createSnippetWithMetadata(file_path, title, prefix, description, new_snippet_file, print_out);

  // Free allocated strings
  free(file_path);
  free(title);
  free(prefix);
  free(description);

  // Create JS string from result
  napi_value js_result;
  status = napi_create_string_utf8(env, result, NAPI_AUTO_LENGTH, &js_result);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to create return value");
    return NULL;
  }

  return js_result;
}
