const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;

const checkFileExists = @import("modify_snippet").checkFileExists;
const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;
const transformFileToFragment = @import("json_parser").transformFileToFragment;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

// ========== Free Memory Utility

export fn freeMemory(ptr: [*c]u8) void {
    _ = ptr;

    // Code to free the memory allocated by allocator.dupeZ
}

// Export this Function - it should accept a C string and return the Snippet String

// export fn returnsCstr(path: [*c]const u8) [*c]const u8 {

//      const allocator =  std.heap.ArenaAllocator...

//      // defer arena.deinit(); uncommenting causes segfault from FFI call

//      const s : []u8 = doSomethingGetString(allocator)
//      convert_s_to_c_str using allocator.dupeZ
//
//      return c_str.ptr // FFI consumes string - but then memory for string is still active
// }

export fn parseFileGetSnippet(file_path: [*c]const u8, print_out: bool) [*c]const u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // Uncommenting this frees the memory and causes a segfault during JS
    // defer arena.deinit();

    // When the library is loaded :
    // the binary is loaded to the Memory Space of the Node Program

    // we provide a way in C to free this memory - by either :
    // 1. Having a Global Allocator not tied to function calls
    // 2. Providing a Free function that uses the C Allocator to the NAPI calls

    const allocator = arena.allocator();

    const zig_file_path = std.mem.span(file_path);

    const snippet = parseFileReturnSnippet(allocator, zig_file_path, print_out) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    const to_string = snippet.toString(allocator) catch |err| {
        std.debug.panic("Failed to Convert to String for File {s}\nErr:{}", .{ zig_file_path, err });
    };

    // Convert the slice to a C-style string if needed - dupeZ null terminates it.
    const c_string = allocator.dupeZ(u8, to_string) catch |err| {
        std.debug.panic("Failed to Convert to C String for File {s}\nErr:{}", .{ zig_file_path, err });
    };
    return c_string.ptr;
}

pub fn parseFileReturnSnippet(allocator: std.mem.Allocator, input_file_path: []const u8, print_stdout: bool) !Snippet {

    // 1. Read File -> Write Snippet to stdout

    const input_file_exists = try checkFileExists(input_file_path);

    if (input_file_exists == false) {
        handleInputFileNotExists(input_file_path);
        return error.FileNotFound;
    }

    // 2. Print Snippet

    const transformed_snippet = try transformFileToFragment(allocator, input_file_path, false);

    if (print_stdout == true) try printFragmentBufferedFileIO(transformed_snippet);

    return transformed_snippet;
}
