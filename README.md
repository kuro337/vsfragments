# vsfragments

<br/>
<br/>

<div align="center">
  <img alt="Kotlin logo" height="200px" src="assets/readme_bg.jpg">
</div>

<br/>
<br/>
<br/>

_100% Zig Native System Tool for creating Code Fragments that can also be embedded into runtimes._

<br/>
<br/>

<hr/>

```bash

# Serialize & Transform, Pretty Format, and Update VS Snippets 
./vsfragments /apps/http.cpp --lang c++ --tidy --update

```

<br/>


```bash

# Serialize & Transform, Pretty Format, and Update VS Snippets 
./vsfragments /apps/http.cpp --lang c++ --tidy --update

```

<br/>

```bash

# Convenient Drop-In JSON Serializer 
./vsfragments /app --json

```



<hr/>

- Do you use write a lot of Code? Do you use VSCode? Have you ever used Code Snippets on VSCode?

<br/>

- If you use VSCode - highly recommend using VSCode Code Snippets - check out their [official overview](https://code.visualstudio.com/docs/editor/userdefinedsnippets).


<br/>



- _100% Zig Code_ built and profiled against `ARM`, `Windows`, and `Linux x86`.

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

# Convenient Drop-In JSON Serializer 
./vsfragments /app --json

```

<br/>


```bash

# Convenient Drop-In JSON Serializer 
./vsfragments /hello.zig -p zig-app --lang zig

# Now in VSCode , start typing 
# Cmd+Space+zig-app / Ctrl+Space+zig-app and the Code Fragment gets Pasted!

# Happy Coding!
```

<br/>

<hr/>

_Begin typing the shortcut & the fragment is pasted into your IDE!_

Mac
- ⌘ *cmd* `+` *space* `+`  *zig-app* 

 <br/>

Windows
- *ctrl* `+` *space* `+`  *zig-app*  

<hr/>

<br/>


Resulting Snippet that VSCode uses as a Zig Code Fragment 
  
<br/>

```json
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
    "```",
  ],
  "description":"Log output to console"
}

```

<hr/>
<br/>

Latest Test Run

```bash
Build Summary: 9/9 steps succeeded; 16/16 tests passed
test success
├─ run test 7 passed 158ms MaxRSS:4M
│  └─ zig test Debug native success 1s MaxRSS:237M
├─ run test 1 passed 116ms MaxRSS:4M
│  └─ zig test Debug native success 1s MaxRSS:199M
├─ run test 7 passed 118ms MaxRSS:4M
│  └─ zig test Debug aarch64-macos success 1s MaxRSS:239M
└─ run test 1 passed 84ms MaxRSS:4M
   └─ zig test Debug aarch64-macos success 1s MaxRSS:197M
```

<hr/>
<br/>

Author: [kuro337](https://github.com/kuro337)