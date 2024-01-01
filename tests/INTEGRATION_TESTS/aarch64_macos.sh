#!/bin/bash


DIM_YELLOW="\e[2;33m" 
NC="\e[0m" 

divider() {
    printf "\n\n${DIM_YELLOW}==============================================================================================\n${NC}\n\n"
}


divider

echo "RUNNING INTEGRATION TESTS FOR aarch64_macos"

divider

echo "Running Colors Inline Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/MOCK_PARSER_DATA/ansi/expected_output.txt
echo "------------------------------------------------------------"

echo "Running Valid File Only Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f ../../mock/testfile.txt
echo "------------------------------------------------------------"

echo "Running Empty Existing File Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f ../../mock/testfile.txt -o ../../mock/pure.code-snippets
echo "------------------------------------------------------------"

echo "Running Invalid Command Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f nosuchfile.txt -o ../../mock/pure.code-snippets
echo "------------------------------------------------------------"

echo "Running Valid Input Output Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f ../../mock/testfile.txt -o ../../mock/populated.code-snippets
echo "------------------------------------------------------------"

echo "Running Valid Input Output File Passed with Create Flag Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f test.txt -o createfile.json -y
echo "------------------------------------------------------------"

echo "Running Valid File with Description + Prefix + Title Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -f ../../mock/testfile.txt --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"

echo "Running Inline with Description + Prefix + Title Test"
cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
  ./vsfragment_fast -c '$transformline\"' --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"


echo "Running Inline Command Outside Using Path Binary"
vsfragment -c '$transformline\"' --title "Snippet Title"  --prefix flowtest.set --desc "set custom description"
echo "------------------------------------------------------------"


divider

echo "COMPLETED RUNNING INTEGRATION TESTS FOR aarch64_macos"

divider