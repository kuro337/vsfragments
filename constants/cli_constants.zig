pub const stdout_section_limiter = "\x1b[90m======================================\x1b[0m";
pub const stdout_result_limiter = "\x1b[90m_____________________\x1b[0m";
pub const stdout_start_star_limiter = "\x1b[90m**********************************************\x1b[0m";

pub const stdout_init_msg = "\x1b[90m**********************************************\x1b[0m\n\x1b[92m\x1b[1mCreating Fragment\x1b[0m\x1b[0m\n\x1b[90m**********************************************\x1b[0m\n";

pub const usage_notes = "\x1b[1mUsage Notes:\x1b[0m";

pub const binary_custom_usage = "- To create a fragment with a custom prefix, description, and title, use the command:\n";
pub const binary_custom_usage_cmd = "\x1b[96m./vsfragment --prefix \"gostructusage\" --desc \"Using Structs in Go\" --title \"Go Structs\"\x1b[0m";
pub const binary_f_o_usage = "- To Directly Append to an Existing Snippets File pass the -f and -o flags";
pub const fragment_input_output_usage = "\x1b[96m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets\x1b[0m";

pub const snippet_optional_args_usage =
    \\ 
    \\ - Prefix: This is a short, unique string used to trigger the snippet in VS Code. Set it using the --prefix flag.
    \\ - Description: A brief explanation of what the snippet does. Use the --desc flag to set it.
    \\ - Title: The title of the snippet, giving a quick idea of its purpose. It can be set using the --title flag.
    \\
;

pub const usages_bold = "\x1b[1mUsages:\x1b[0m";

pub const success_fragment_usage = "\x1b[97mPaste above into the VSCode \x1b[1m.code-snippets\x1b[22m\x1b[97m file and begin typing \x1b[1mCommand + Space\x1b[22m\x1b[97m and the \x1b[1mPrefix\x1b[22m\x1b[97m \x1b[37m(gohttp...)\x1b[97m to paste the Snippet into your IDE.\x1b[0m";

pub const successfully_created_inline_msg = "\x1b[92mSuccessfully Generated Fragment from Inline Input\x1b[0m";

pub const successfully_created_fileio_msg = "\x1b[92mSuccessfully Generated Fragment from Input File.\x1b[0m";

pub const not_found_create_recommendation = "\x1b[37mTo create a new file at the specificied location use the -y flag with -o.\x1b[0m";
pub const create_recc_cmd = "\x1b[96m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m";

pub const msg_outputfile_missing = "\x1b[37mTo create a new file at the specificied location use the \x1b[1m-y\x1b[0m flag with \x1b[1m-o\x1b[0m.\x1b[0m\n\n\x1b[97m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m";
// Sky Blue
// \x1b[96m<string>\x1b[0m

// Deep Blue
// try w.print("{s}!", .{"\x1b[94m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets\x1b[0m "});

// Light Purple
// \x1b[95mThis text will be light purple\x1b[0m"

// ./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y

//pub const not_found_create_recommendation = "
// \x1b[37mTo create a new file at the specificied location use the \x1b[1m-y\x1b[0m flag with \x1b[1m-o\x1b[0m.\x1b[0m\n\x1b[96m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m
