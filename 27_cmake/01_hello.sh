source "$(dirname "$0")/lib.sh"; cd ~/cmake-hello; clear
note "Ein Quelltext, eine CMakeLists.txt"
run "ls"
run "cat main.cpp" 2
run "cat CMakeLists.txt" 4
note "Schritt 1: konfigurieren und generieren. Kompiliert wird noch nichts."
run "cmake -S . -B build" 3
run "ls build" 3
note "CMake hat ein Makefile erzeugt und den Compiler im Cache notiert"
run "grep CMAKE_CXX_COMPILER: build/CMakeCache.txt" 2.5
note "Schritt 2: bauen. cmake --build ruft das erzeugte Build-System auf."
run "cmake --build build" 2.5
run "./build/hello" 2
note "Der Quellbaum bleibt sauber, alles Erzeugte liegt in build/"
run "ls" 2
note "Noch einmal bauen: nichts zu tun"
run "cmake --build build" 2
note "Frischer Start: build/ einfach löschen"
run "rm -r build && ls" 2
fin
