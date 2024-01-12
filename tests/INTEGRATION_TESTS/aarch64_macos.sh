#!/bin/bash


DIM_YELLOW="\e[2;33m" 
BRIGHT_BLUE='\033[1;96m'

NC="\e[0m" 

divider() {
    printf "\n\n${DIM_YELLOW}==============================================================================================\n${NC}\n\n"
}

runtest() {
    printf "\n\n${BRIGHT_BLUE}********************\n${NC}\n\n"
}

divider

echo "RUNNING INTEGRATION TESTS FOR aarch64_macos"

divider

runtest
echo "Running Colors Inline Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock_PARSER_DATA/ansi/expected_output.txt
echo "------------------------------------------------------------"

runtest
echo "Running Valid File Only Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/validfile.txt
echo "------------------------------------------------------------"

runtest
echo "Running Empty Existing File - with no -y Flag passed to Create NEW FILE"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/validfile.txt -o /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/doesnotexist.code-snippets -y
echo "------------------------------------------------------------"

runtest
echo "Running Invalid Command Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f nosuchfile.txt -o /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/pure.code-snippets
echo "------------------------------------------------------------"

runtest
echo "Running Valid Input Output Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/validfile.txt -o /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/newfile.code-snippets -y
echo "------------------------------------------------------------"

runtest
echo "Running Valid Input Output File Passed with Create Flag Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/validfile.txt -o integrationoutput.json -y
echo "------------------------------------------------------------"

runtest
echo "Running Valid File with Description + Prefix + Title Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/utf8_or_binary/validfile.txt --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"

runtest
echo "Running Inline with Description + Prefix + Title Test"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -c '$transformline\"' --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"

runtest
echo "Running Inline Command Outside Using Path Binary"
runtest
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment -c '$transformline\"' --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"


runtest
echo "Running Dir Convert"
runtest

cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin/macos/aarch64/ReleaseFast && \
./vsfragment --dir /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/input -o /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/output/testing.code-snippets

rm /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/output/testing.code-snippets

divider

echo "COMPLETED RUNNING INTEGRATION TESTS FOR aarch64_macos"

divider