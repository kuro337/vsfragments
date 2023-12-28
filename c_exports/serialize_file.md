# Serialize File


- `serializeFileReturnParsed(file_path)` - generates the `struct` - then uses the `toString()` method I defined to return the final result `C String` which is consumed by FFI

  - That's why I didnt clear the Allocator in `serializeFileReturnParsed` 
  

- `readLinesFromFile(alloc,file_path)` :  

  -  reads a File from Disk and returns in a `[][]const u8`  

- `MyStruct` has a method `createFromLines(allocator, file_lines)`

  - `createFromLines()` - acepts a ``[][]const u8` - performs transformations and creates a final Slice - which is set as a Prop on the `MyStruct` object.


```rust

export fn serializeFileReturnParsed(file_path: [*c]const u8) [*c]const u8 {
  var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // Uncommenting this frees the memory and causes a segfault during FFI usage
    // defer arena.deinit();

    // convert [*c]const u8 -> [] const u8 (assuming this is simply type conversion)
    const zig_file_path = std.mem.span(file_path);

    const custom_struct = transformFileToFragment(allocator, zig_file_path) 

    // Struct has a toString() that creates a new []u8 from 
    // the document lines [][]u8
    const to_string = snippet.toString(allocator)
        
    // Convert the slice to a C-style string - dupeZ null terminates it.
    const c_string = allocator.dupeZ(u8, to_string)
        
    return c_string.ptr;

}



pub fn transformFileToFragment(allocator, file_path: []const u8) !MyStruct {
  
  const file_lines :[][]const u8 = try readLinesFromFile(allocator, file_path);
  // should defer free file_lines here

    const custom_struct = try MyStruct.createFromLines(allocator, file_lines);
    
    // dont need file_lines - we transformed it and file_lines.toSliceOwned() is set as a prop on the Struct


    return custom_struct;
}

```

- Reading Lines from File

```rust
pub fn readLinesFromFile(allocator, filename: []const u8) ![][]const u8 {

// 1. Create ArrayList to hold each Line from File 

// 2. Loop over File - allocate a []u8 

// 3. Append a copy a of the []u8 to ArrayList

// 4, in the end convert ArrayList to a [][]const u8 and return

// this function definitely needs to be vastly improved

  
}

```


- MyStruct `createLines()`

```rust
// transform passed [][]u8 and set Struct Props
pub fn createFromLines(allocator, lines: []const []const u8) !MyStruct {

        var parsedLines = std.ArrayList([]const u8).init(allocator); // unknown length
        // should defer parsedLines too 


        // for each line in lines -

            // create new ArrayList + Defer it to construct new Strings

            // end of each loop iteration - append to parsedLines

        
        // once full parsedLines created - 

        return MyStruct {
          .body = try parsedLines.toOwnedSlice(),
        }

}

```
