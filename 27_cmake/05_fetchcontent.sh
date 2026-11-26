source "$(dirname "$0")/lib.sh"; cd ~/fetch_demo; clear
note "Das Programm benutzt eine Bibliothek, die nicht im Projekt liegt"
run "tree" 2.5
run "cat src/main.cpp" 3
run "cat CMakeLists.txt" 6
note "Konfigurieren holt die Bibliothek von GitHub (braucht Netz)"
run "cmake -B build" 4
note "Der Code liegt unter build/_deps, nicht im Quellbaum"
run "ls build/_deps" 2.5
run "ls build/_deps/stemgraph_cmake_lib-src" 3
note "Dort bringt die Bibliothek ihre eigene CMakeLists.txt mit"
run "grep -v -e ^# -e ^\$ build/_deps/stemgraph_cmake_lib-src/CMakeLists.txt" 5
note "Bauen: erst die Bibliothek, dann unser Programm"
run "cmake --build build" 3
run "./build/fetch_demo" 3
note "Im Projekt ist nur build/ dazugekommen"
run "tree -L 1" 2.5
fin
