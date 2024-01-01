// from_js.h
#ifndef FROM_JS_H
#define FROM_JS_H

#include <node_api.h>

napi_value receiveStringFromJS(napi_env env, napi_callback_info args);

napi_value ZigParseStringFromJS(napi_env env, napi_callback_info args);

napi_value ZigParseFileGetSnippet(napi_env env, napi_callback_info args);

napi_value ZigCreateSnippetWithMetadata(napi_env env, napi_callback_info args);

#endif // FROM_JS_H
