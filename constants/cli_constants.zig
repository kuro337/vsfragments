pub const newline = "\n";
pub const double_newline = "\n\n";
pub const triple_newline = "\n\n\n";

pub const large_star_delimiter = "\x1b[90m*******************************************************************************\x1b[0m";

pub const stdout_section_limiter = "\x1b[90m======================================\x1b[0m";
pub const stdout_result_limiter = "\x1b[90m_____________________\x1b[0m";
pub const stdout_start_star_limiter = "\x1b[90m**********************************************\x1b[0m";

pub const stdout_init_msg = "\x1b[90m_____________________________\x1b[0m\n\x1b[92m\x1b[1m Creating Fragment\x1b[0m\x1b[0m\n\x1b[90m_____________________________\x1b[0m\n";

pub const usage_notes = "\x1b[1mAdditional Optional Flags:\x1b[0m";

// INIT_MESSAGES
pub const stdout_passed_snippet_file_output = "\x1b[90m*******************************************************************************\x1b[0m\n\x1b[97m Passed Snippet File and Output\x1b[0m\n\x1b[90m*******************************************************************************\x1b[0m";
pub const stdout_passed_inline_text = "\x1b[90m*******************************************************************************\x1b[0m\n\x1b[97m Passed Inline Snippet\x1b[0m\n\x1b[90m*******************************************************************************\x1b[0m";

// EXECUTION_MESSAGES
pub const output_file_not_exists = "\x1b[1m\x1b[31mFile Not Found\x1b[0m\n\n\x1b[31mOutput Path Snippets File does not exist.\x1b[0m\n";

pub const STANDARD_USAGE_EXAMPLES = newline ++ binary_custom_usage ++ newline ++ binary_custom_usage_cmd ++ triple_newline ++ binary_f_o_usage ++ double_newline ++ fragment_input_output_usage;

// -f -o success message

pub const FILEIO_AFTER_CMD_MSG = newline ++
    stdout_init_msg ++
    newline ++
    stdout_section_limiter ++ stdout_section_limiter ++
    newline ++
    successfully_created_fileio_msg ++
    newline ++
    stdout_section_limiter ++ stdout_section_limiter ++ double_newline ++
    success_fragment_usage ++ newline ++ stdout_section_limiter ++ double_newline;

pub const binary_custom_usage = "- to create a fragment with a custom prefix, description, and title, run:\n";
pub const binary_custom_usage_cmd = "\x1b[94m./vsfragment\x1b[0m --prefix \"gostructusage\" --desc \"Using Structs in Go\" --title \"Go Structs\"";
pub const binary_f_o_usage = "- To Directly Append to an Existing Snippets File pass the -f and -o flags";
pub const fragment_input_output_usage = "\x1b[94m./vsfragment\x1b[0m -f djikstras.md -o /users/code/dsa.code-snippets";

pub const snippet_optional_args_usage =
    \\ 
    \\ - Prefix: This is a short, unique string used to trigger the snippet in VS Code. Set it using the --prefix flag.
    \\ - Description: A brief explanation of what the snippet does. Use the --desc flag to set it.
    \\ - Title: The title of the snippet, giving a quick idea of its purpose. It can be set using the --title flag.
    \\
;

pub const usages_bold = "\x1b[1mUsages:\x1b[0m";

pub const success_fragment_usage = "\x1b[97mPaste fragment into the VSCode \x1b[1m.code-snippets\x1b[22m\x1b[97m file and begin typing \x1b[1mCommand + Space\x1b[22m\x1b[97m and the \x1b[1mPrefix\x1b[22m\x1b[97m \x1b[37m(gohttp...)\x1b[97m to paste the Snippet into your IDE.\x1b[0m";

pub const successfully_created_inline_msg = "\x1b[92mSuccessfully Generated Fragment from Inline Input\x1b[0m";

pub const successfully_created_fileio_msg = "\x1b[92mSuccessfully Generated Fragment from Input File.\x1b[0m";

pub const not_found_create_recommendation = "\x1b[37mTo create a new file at the specificied location use the -y flag with -o.\x1b[0m";
pub const create_recc_cmd = "\x1b[94m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m";

pub const msg_outputfile_missing = "\x1b[37mTo create a new file at the specificied location use the \x1b[1m-y\x1b[0m flag with \x1b[1m-o\x1b[0m.\x1b[0m\n\n\x1b[97m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m";

// FILE NOT FOUND CONSTANTS
pub const bold_white_single_quote = "\x1b[97m\x1b[1m'\x1b[0m\x1b[97";

pub const not_found_inline_cmd_partial = "Optionally snippets can also be created from an Inlined Command.\n\n";

pub const vsfragment_inline_cmd_desc = "- generate a Snippet using Inlined Text";

pub const vsfragment_inline_cmd_start = "\x1b[94m./vsfragment\x1b[0m -c \x1b[97m\x1b[1m'\x1b[0m\x1b[97\x1b[90mimport csv\n";
pub const vsfragment_inline_cmd_mid =
    \\output_file_path = "output.csv"  # Replace with your desired output CSV file path
    \\with open(input_file_path, "r") as infile, open(output_file_path, "w", newline="") as outfile:
    \\    reader = csv.reader(infile, delimiter="|")
    \\    writer = csv.writer(outfile)
    \\    for row in reader:
    \\        writer.writerow(row)
;
pub const vsfragment_inline_cmd_end = bold_white_single_quote ++ "\x1b[0m";

// Full Line for INLINED ./vsfragment Usage
pub const USAGE_INLINE_CMD = vsfragment_inline_cmd_start ++ vsfragment_inline_cmd_mid ++ vsfragment_inline_cmd_end;

pub const not_found_reminder_greydim = "\x1b[90mRecommended Usage is by creating a file and using the -f flag.\x1b[0m\n";
pub const not_found_reminder_yellowdim = "\x1b[2;33mRecommended Usage is by creating a file and using the -f flag.\x1b[0m\n";
pub const not_found_reminder_yellowbold = "\x1b[1;33mRecommended Usage is by creating a file and using the -f flag.\x1b[0m\n";
pub const not_found_reminder_yellowitalic = "\x1b[33;3mRecommended Usage is by creating a file and using the -f flag.\x1b[0m\n";
pub const not_found_reminder_yellow = "\x1b[33mRecommended Usage is by creating a file and using the -f flag\x1b[0m\n";

pub const INPUT_FILE_NOT_FOUND_MSG = not_found_inline_cmd_partial ++ USAGE_INLINE_CMD ++ double_newline ++ not_found_reminder_yellow ++ double_newline;

// HELP CONSTANTS

pub const help_main_title = "\x1b[92mvsfragment\x1b[0m - \x1b[1mCreate reusable Code Fragments for reuse and rapid development\x1b[0m";

pub const stdout_help_msg = "\x1b[90m*******************************************************************************\x1b[0m\n\x1b[92mvsfragment\x1b[0m - \x1b[1mCreate reusable Code Fragments for reuse and rapid development\x1b[0m\n\x1b[90m*******************************************************************************\x1b[0m";
pub const help_flags_main_header = "\x1b[1mUsage:\x1b[0m \x1b[94mvsfragment\x1b[0m [flags]";
pub const help_basic_cmd = "- create vsfragment\n\n\x1b[94m./vsfragment\x1b[0m -f anyfile.md";
pub const help_filio_cmd = "- create vsfragment & Update Snippets File (recommended usage paste text into a file and use -f flag)\n\n\x1b[94m./vsfragment\x1b[0m -f djikstras.md -o /users/code/dsa.code-snippets";
pub const help_inline_cmd_partial = "create code snippet from inline input\n\n\x1b[96m./vsfragment -c\x1b[0m \x1b[97m\x1b[1m'\x1b[0m\x1b[97import csv\n";
const help_inline_cmd_remaining =
    \\output_file_path = "output.csv"  # ouput csv path
    \\with open(input_file_path, "r") as infile, open(output_file_path, "w", newline="") as outfile:
    \\    reader = csv.reader(infile, delimiter="|")
    \\    writer = csv.writer(outfile)
    \\    for row in reader:
    \\        writer.writerow(row)'
;

pub const help_star_delimiter = "\x1b[90m*****************************************************************\x1b[0m";
pub const help_flags_usage_header = "\x1b[1mFlags:\x1b[0m";

const help_flags_multiline =
    \\  -f, --file    <file path>     Path to a VSCode Snippet File
    \\  -o, --output <file_path>     Path to an Existing VSCode Snippets File or Empty File
    \\  -c, --code   <string...>    Code String to convert. Supports Multiline.
    \\  -l, --lang   <language>     Language of the Code String
    \\  -p, --print                 Print the Fragment to stdout
    \\  -h, --help                  Print this help message
    \\
    \\ Optional Flags: 
    \\
    \\  --prefix      <prefix>        Prefix for the Fragment
    \\  --title      <title>        Title for the Fragment
    \\  --desc       <description>  Description for the Fragment
    \\
;

pub const HELP_MSG = newline ++ stdout_help_msg ++ double_newline ++
    help_flags_main_header ++ double_newline ++ double_newline ++
    help_basic_cmd ++
    double_newline ++
    stdout_result_limiter ++ double_newline ++
    help_filio_cmd ++ double_newline ++
    stdout_result_limiter ++ double_newline ++
    vsfragment_inline_cmd_desc ++ double_newline ++
    USAGE_INLINE_CMD ++ double_newline ++
    help_star_delimiter ++ double_newline ++
    help_flags_usage_header ++ double_newline ++
    help_flags_multiline ++ newline ++
    help_star_delimiter ++ double_newline;

// Pass Text Directly through your Shell to Generate the Fragment
// Create vsfragment & Update Snippets File (recommended usage paste text into a file and use -f flag)

// -h Help print uses constants -

// 1. stdout_help_msg +2n
// 2. help_flags_main_header +2n
// 3. help_basic_cmd +2n
// 4. help_filio_cmd +2n
// 5. help_inline_cmd_partial + \n + remaining inline command multiline +2n
// 6. help_star_delimiter + help_flags_usage_header + 2n + help_flags_multiline + 1n + help_star_delimiter

//comptime full_help_msg = {}

// vsfragment - Create reusable Code Fragments for reuse and rapid development

// Sky Blue
// \x1b[96m<string>\x1b[0m

// Deep Blue
// try w.print("{s}!", .{"\x1b[94m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets\x1b[0m "});

// Light Purple
// \x1b[95mThis text will be light purple\x1b[0m"

// ./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y

//pub const not_found_create_recommendation = "
// \x1b[37mTo create a new file at the specificied location use the \x1b[1m-y\x1b[0m flag with \x1b[1m-o\x1b[0m.\x1b[0m\n\x1b[96m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m
