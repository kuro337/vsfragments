<br/>

# vsfragments

<br/>
<br/>

<div align="center">
  <img alt="Kotlin logo" height="200px" src="assets/readme_bg.jpg">
</div>

<br/>
<br/>
<br/>

_Simple, Lightweight, Lightning Fast_ Native System Binary for generating Code Fragments.

<br/>

Embeddedable and extensible directly as a Static Library from **C** or **Node**.

<br/>

<br/>

```bash
$ vsfragment


================================================================================
*
* vsfragment - Create reusable Code Fragments for reuse and rapid development
*
================================================================================



Usage: vsfragment [flags]


- create vsfragment

vsfragment -f anyfile.md

_____________________


- create vsfragment & Update Snippets File

vsfragment -f djikstras.md -o /users/code/dsa.code-snippets

_____________________


- generate a Snippet using Inlined Text

vsfragment -c 'import csv
output_file_path = "output.csv"
with open(input_path, "r") as infile, open(out_path, "w", newline="") as outfile:
    reader = csv.reader(infile, delimiter="|")
    writer = csv.writer(outfile)
    for row in reader:
        writer.writerow(row)'

================================================================================

Flags:

  -f, --file   <file path>     Path to a VSCode Snippet File
  -o, --output <file_path>     Path to a VSCode Snippets File or any file
  -c, --code   <string...>     Code String to convert. Supports Multiline.
  -l, --lang   <language>      Language of the Code String
  -p, --print                  Print the Fragment to stdout
  -h, --help                   Print this help message

 Optional Flags:

  --prefix     <prefix>       Prefix for the Fragment
  --title      <title>        Title for the Fragment
  --desc       <description>  Description for the Fragment

================================================================================

```

<br/>
<br/>

<hr/>

<br/>

- Write a lot of **Code** & use **VSCode**?

<br/>

- Highly recommend checking out VSCode Code Snippets! check out their [official overview](https://code.visualstudio.com/docs/editor/userdefinedsnippets).

<br/>

- **_VSCode Extension_** coming soon that uses this same library behind the hood using **ffi**

<br/>

```bash

- generate a Snippet using inlined text directly from your shell

vsfragment -c 'import csv
output_file_path = "output.csv"
with open(input_path, "r") as infile, open(out_path, "w", newline="") as outfile:
    reader = csv.reader(infile, delimiter="|")
    writer = csv.writer(outfile)
    for row in reader:
        writer.writerow(row)'


# output

============================================================================
Successfully Generated Fragment from Inline Input
============================================================================

"Go HTTP2 Server Snippet": {
        "prefix": "python_read_file",
        "body": [
                "import csv",
                "output_file_path = \"output.csv\"",
                "with open(input_file_path, \"r\") as infile",
                "   \treader = csv.reader(infile, delimiter=\"|\")",
                "   \twriter = csv.writer(outfile)",
                "   \tfor row in reader:",
                "   \t   \twriter.writerow(row)"
        ],
        "description": "type python_read_file in vscode to use snippet. velocity!"
}

============================================================================
Paste fragment into the VSCode .code-snippets file and
begin typing Command + Space and the Prefix (gohttp...)
to paste the Snippet into your IDE.
```

<hr/>

<br/>

built and profiled against

- aarch64_macos
- x86_64_linux

- x86_64_windows

<br/>

## Build from Source

<br/>

```bash

$ zig build  --summary all


builds 4 Releases :

- release-safe
- release-fast
- release-small
- debug

cd zig-out/native/

- vsfragment_safe
- vsfragment_fast
- vsfragment_debug
- vsfragment_small


./vsfragment_fast # prints help


# Unit Tests

$ zig build test --summary all

# Integration Tests

cd TESTS/INTEGRATION_TESTS && ./aarch64_macos.sh
cd TESTS/INTEGRATION_TESTS && ./x86_64_linux.sh
cd TESTS/INTEGRATION_TESTS && ./x86_64_windows.sh

```

<br/>

<br/>

Complete steps to setup the **Compiler** and **Language Server** are included.

<br/>

[Installing Zig](docs/installing_zig/steps.md)

<br/>

[Language Server Setup](docs/ide/lang_server.md)

<br/>

<hr/>

<br/>

**Usage**

<br/>

```rust

# Threading OS Threads

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const eql = std.mem.eql;
const Thread = std.Thread;

pub fn main() !void {
    std.debug.print("{s}\n", .{"Hello, world!"});
}
```

<br/>

```bash

# Convenient , Simple , and Extremely Fast and Memory Efficient

vsfragments app --json


# Pass an existing Output file and keep adding more snippets to it

vsfragments -f input.kt -o /path/to/kotlin.snippets -y

```

<hr/>

 <br/>

Begin typing the shortcut & the fragment is pasted into your IDE

 <br/>

Mac

⌘ _cmd_ `+` _space_ `+` _zig-app_

 <br/>

Windows

_ctrl_ `+` _space_ `+` _zig-app_

<hr/>

<br/>

Resulting Snippet that VSCode uses as a Zig Code Fragment

<br/>

````json
{
  "prefix": "testparse",
  "body": [
    "# Threading OS Threads",
    "",
    "```rust",
    "const std = @import(\"std\");",
    "const expect = std.testing.expect;",
    "const print = std.debug.print;",
    "const ArrayList = std.ArrayList;",
    "const test_allocator = std.testing.allocator;",
    "const eql = std.mem.eql;",
    "const Thread = std.Thread;",
    "",
    "pub fn main() !void {",
    "\tstd.debug.print(\"{s}\\n\", .{\"Hello, world!\"});",
    "}",
    "```"
  ],
  "description": "Log output to console"
}
````

<hr/>
<br/>

## Latest Build Release

<br/>

```bash
$ zig build --summary all

$ zig version 0.11.0  # stable
$ zig version 0.12.0-dev.2059+42389cb9c # latest master


Build Summary: 33/33 steps succeeded
install success
├─ install vsfragment_fast success
│  └─ zig build-exe vsfragment_fast ReleaseFast native success 7s MaxRSS:265M
├─ install vsfragment_safe success
│  └─ zig build-exe vsfragment_safe ReleaseSafe native success 8s MaxRSS:291M
├─ install vsfragment_debug success
│  └─ zig build-exe vsfragment_debug Debug native success 9s MaxRSS:203M
├─ install vsfragment_small success
│  └─ zig build-exe vsfragment_small ReleaseSmall native success 899ms MaxRSS:138M
├─ install vsfragment_fast success
│  └─ zig build-exe vsfragment_fast ReleaseFast aarch64-macos success 9s MaxRSS:259M
├─ install vsfragment_safe success
│  └─ zig build-exe vsfragment_safe ReleaseSafe aarch64-macos success 9s MaxRSS:304M
├─ install vsfragment_debug success
│  └─ zig build-exe vsfragment_debug Debug aarch64-macos success 1s MaxRSS:210M
├─ install vsfragment_small success
│  └─ zig build-exe vsfragment_small ReleaseSmall aarch64-macos success 8s MaxRSS:136M
├─ install vsfragment_fast success
│  └─ zig build-exe vsfragment_fast ReleaseFast x86_64-linux success 7s MaxRSS:276M
├─ install vsfragment_safe success
│  └─ zig build-exe vsfragment_safe ReleaseSafe x86_64-linux success 9s MaxRSS:318M
├─ install vsfragment_debug success
│  └─ zig build-exe vsfragment_debug Debug x86_64-linux success 1s MaxRSS:217M
├─ install vsfragment_small success
│  └─ zig build-exe vsfragment_small ReleaseSmall x86_64-linux success 1s MaxRSS:137M
├─ install vsfragment_fast success
│  └─ zig build-exe vsfragment_fast ReleaseFast x86_64-windows success 2s MaxRSS:173M
├─ install vsfragment_safe success
│  └─ zig build-exe vsfragment_safe ReleaseSafe x86_64-windows success 8s MaxRSS:347M
├─ install vsfragment_debug success
│  └─ zig build-exe vsfragment_debug Debug x86_64-windows success 9s MaxRSS:186M
└─ install vsfragment_small success
   └─ zig build-exe vsfragment_small ReleaseSmall x86_64-windows success 2s MaxRSS:133M

```

<hr/>

<br/>

## Latest Test Run

<br/>

```bash

$ zig build test --summary all

Build Summary: 25/25 steps succeeded; 42/42 tests passed
test success
├─ run test 6 passed 317ms MaxRSS:5M
│  └─ zig test Debug native success 4s MaxRSS:342M
├─ run test 4 passed 76ms MaxRSS:2M
│  └─ zig test Debug native success 4s MaxRSS:288M
├─ run test 13 passed 246ms MaxRSS:1M
│  └─ zig test Debug native success 4s MaxRSS:278M
├─ run test 5 passed 282ms MaxRSS:2M
│  └─ zig test Debug native success 4s MaxRSS:325M
├─ run test 2 passed 213ms MaxRSS:1M
│  └─ zig test Debug native success 4s MaxRSS:288M
├─ run test 1 passed 59ms MaxRSS:2M
│  └─ zig test Debug native success 3s MaxRSS:288M
├─ run test 1 passed 95ms MaxRSS:2M
│  └─ zig test Debug native success 4s MaxRSS:286M
├─ run test 1 passed 59ms MaxRSS:2M
│  └─ zig test Debug native success 4s MaxRSS:288M
├─ run test 2 passed 132ms MaxRSS:4M
│  └─ zig test Debug native success 4s MaxRSS:291M
├─ run test 4 passed 182ms MaxRSS:7M
│  └─ zig test Debug native success 4s MaxRSS:305M
├─ run test 2 passed 112ms MaxRSS:1M
│  └─ zig test Debug native success 4s MaxRSS:286M
└─ run test 1 passed 182ms MaxRSS:2M
   └─ zig test Debug native success 4s MaxRSS:303M

```

<br/>

```bash
COMPLETED RUNNING 9 INTEGRATION TESTS FOR aarch64_macos

COMPLETED RUNNING 9 INTEGRATION TESTS FOR x86_64_linux
```

<hr/>
<br/>

[Foreign Function Interface](ffi_interface/ffi.d.ts)

<hr>
<br/>

Author: [kuro337](https://github.com/kuro337)
