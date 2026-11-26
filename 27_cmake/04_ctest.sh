source "$(dirname "$0")/lib.sh"; cd ~/cmake-ctest; clear
note "Eine Bibliothek, ein Programm und zwei Testprogramme"
run "tree" 3
run "tail -5 CMakeLists.txt" 3
run "cat tests/CMakeLists.txt" 6
run "cmake -S . -B build > /dev/null && cmake --build build" 3
note "ctest läuft im Build-Verzeichnis. Ein Test besteht mit Exit-Status 0."
run "cd build" 0.5
run "ctest" 4
note "Ein absichtlicher Fehler: is_prime(1) wird wahr"
run "sed -i 's/n < 2/n < 1/' ../src/numbers.cpp" 1
run "cmake --build . > /dev/null && ctest" 4
note "Was hat der Test ausgegeben?"
run "ctest -R prime --output-on-failure" 5
note "Fehler beheben, aber NICHT neu bauen"
run "sed -i 's/n < 1/n < 2/' ../src/numbers.cpp" 1
run "ctest -R prime" 4
note "ctest baut nicht: es lief das alte Testprogramm. Erst bauen, dann testen."
run "cmake --build . > /dev/null && ctest -R prime" 4
note "Auswahl über Labels, Liste ohne Ausführung mit -N"
run "ctest -N" 3
run "ctest -L cli" 4
note "Ein Test, der hängen kann, bekommt ein TIMEOUT"
run "echo 'add_test(NAME slow COMMAND sleep 3)' >> ../tests/CMakeLists.txt" 1
run "echo 'set_tests_properties(slow PROPERTIES TIMEOUT 1)' >> ../tests/CMakeLists.txt" 1
run "cmake --build . > /dev/null && ctest -j4" 5
fin
