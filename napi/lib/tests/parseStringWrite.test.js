const { parseStringWriteToFile } = require("../export");

describe("ffi-esm tests", () => {
  test("testFunc, returns expected string", () => {
    const exp = "123";
    const act = "123";

    const somestr = `"  status = register_napi_function(env, exports, "parseStringWriteToFile", ZigParseStringWriteToFile);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to register function for parseStringWriteToFile");
  }"`;

    const test_s = "../curr.json";

    const test_new_snip = parseStringWriteToFile(
      somestr,
      test_s,
      "",
      "",
      "",
      true,
      true,
      true
    );

    console.log(test_new_snip);

    expect(exp).toBe(act);
  });
});
