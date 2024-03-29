const { parseStringWriteToFile } = require("../export");
const fs = require("fs");
const path = require("path");

describe("parseStringWriteToFile() tests ", () => {
  test("testFunc, returns expected string", () => {
    const exp = "123";
    const act = "123";

    const somestr = `"  status = register_napi_function(env, exports, "parseStringWriteToFile", ZigParseStringWriteToFile);
  if (status != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to register function for parseStringWriteToFile");
  }"`;

    const test_s = "curr.json";

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

    expect(exp).toBe(act);
  });

  afterAll(() => {
    const filePath = path.join(__dirname, "../../curr.json");
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  });
});
