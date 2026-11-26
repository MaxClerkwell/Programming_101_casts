source "$(dirname "$0")/lib.sh"; cd ~/cmake-buildtypes; clear
note "Das Programm: ein absichtlich falsches assert und eine langsame Schleife"
run "grep -n -B2 -A2 assert main.cpp | tail -6" 3
run "cat CMakeLists.txt" 4
note "Ein Build-Verzeichnis pro Build-Typ, dieselben Quellen"
run "cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug" 2.5
run "cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release > /dev/null" 1
run "ls" 2
note "Mit --verbose sieht man die Compiler-Zeile. Debug: -g"
run "cmake --build build-debug --verbose | grep -- ' -c '" 4
note "Release: -O3 -DNDEBUG. Ohne assert ist x unbenutzt: eine Warnung nur im Release."
run "cmake --build build-release --verbose | grep -- ' -c '" 4
note "Debug: langsam, und das assert schlägt zu"
run "time ./build-debug/app" 4 sub
note "Release: NDEBUG entfernt das assert, die Schleife ist optimiert"
run "time ./build-release/app" 4
note "Der Build-Typ steht im Cache des Build-Verzeichnisses"
run "grep CMAKE_BUILD_TYPE build-*/CMakeCache.txt" 3
note "Eigene Cache-Variable mit -D setzen"
run "cmake -S . -B build-release -DAPP_GREETING='Hi there' > /dev/null" 1
run "cmake --build build-release &> /dev/null && ./build-release/app | head -2" 3
note "Der Wert bleibt im Cache, auch ohne -D beim nächsten Aufruf"
run "cmake -LH -N build-release | grep -A1 Greeting" 3
note "Der Generator gehört zum Build-Verzeichnis"
run "cmake -S . -B build-release -G Ninja" 4
fin
