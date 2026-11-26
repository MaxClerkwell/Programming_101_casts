source "$(dirname "$0")/lib.sh"; cd ~/cmake-libs; clear
note "Zwei Bibliotheken und eine Anwendung, je eine CMakeLists.txt"
run "tree" 4
run "cat CMakeLists.txt" 4
run "cat geometry/CMakeLists.txt" 4
run "cat report/CMakeLists.txt" 4
run "cat app/CMakeLists.txt" 3
run "cmake -S . -B build > /dev/null && cmake --build build" 3
run "./build/app/app" 2.5
note "Ohne Schlüsselwort entstehen statische Bibliotheken"
run "find build -name '*.a' -o -name '*.so'" 3
note "report.hpp bindet einen Header von geometry ein. Was passiert mit PRIVATE?"
run "sed -i 's/report PUBLIC geometry/report PRIVATE geometry/' report/CMakeLists.txt" 1
run "tail -1 report/CMakeLists.txt" 2
run "cmake --build build 2>&1 | grep -B2 -A4 'fatal error'" 5
note "app findet den Header nicht mehr: geometry gehört zur Schnittstelle, also PUBLIC"
run "sed -i 's/report PRIVATE geometry/report PUBLIC geometry/' report/CMakeLists.txt" 1.5
note "Dieselben Quellen als Shared Libraries, ohne eine Zeile zu ändern"
run "cmake -S . -B build-shared -DBUILD_SHARED_LIBS=ON > /dev/null && cmake --build build-shared > /dev/null" 1
run "find build-shared -name '*.so'" 2.5
run "ldd build-shared/app/app | grep -E 'geometry|report'" 3.5
run "readelf -d build-shared/app/app | grep -E 'RPATH|RUNPATH'" 3.5
note "Installieren: CMake entfernt den RUNPATH in das Build-Verzeichnis"
run "cmake --install build-shared --prefix \$PWD/stage" 3
run "./stage/bin/app" 4
note "Abhilfe: CMAKE_INSTALL_RPATH mit \$ORIGIN, vor add_subdirectory"
run "sed -i '/add_subdirectory(geometry)/i set(CMAKE_INSTALL_RPATH \"\$ORIGIN/../lib;\$ORIGIN\")' CMakeLists.txt" 1
run "grep -n RPATH CMakeLists.txt" 2.5
run "cmake --build build-shared > /dev/null && cmake --install build-shared --prefix \$PWD/stage2 > /dev/null" 1
run "./stage2/bin/app" 2.5
run "readelf -d stage2/bin/app | grep -E 'RPATH|RUNPATH'" 3.5
fin
