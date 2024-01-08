#!/bin/bash


DIM_YELLOW="\e[2;33m" 
NC="\e[0m" 

divider() {
    printf "\n\n${DIM_YELLOW}==============================================================================================\n${NC}\n\n"
}

divider

echo "RUNNING INTEGRATION TESTS FOR x86_64_linux"

divider

echo "Running Colors Inline Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/MOCK_PARSER_DATA/ansi/expected_output.txt
echo "------------------------------------------------------------"

echo "Running Valid File Only Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f ../../tests/mock/utf8_or_binary/validfile.txt
echo "------------------------------------------------------------"

echo "Running Empty Existing File Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f ../../tests/mock/utf8_or_binary/validfile.txt -o ../../tests/mock/utf8_or_binary/.code-snippets
echo "------------------------------------------------------------"

echo "Running Invalid Command Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f nosuchfile.txt -o ../../tests/mock/utf8_or_binary/pure.code-snippets
echo "------------------------------------------------------------"

echo "Running Valid Input Output Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f ../../tests/mock/utf8_or_binary/validfile.txt -o ../../tests/mock/utf8_or_binary/populated.code-snippets
echo "------------------------------------------------------------"

echo "Running Valid Input Output File Passed with Create Flag Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f test.txt -o createfile.json -y
echo "------------------------------------------------------------"

echo "Running Valid File with Description + Prefix + Title Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f ../../tests/mock/utf8_or_binary/validfile.txt --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"

echo "Running Inline with Description + Prefix + Title Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -c '$transformline\"' --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"


echo "Running Inline Command Outside Using Path Binary"
./vsfragment -c '$transformline\"' --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"


divider

echo "COMPLETED RUNNING  9 INTEGRATION TESTS FOR x86_64_linux"


divider