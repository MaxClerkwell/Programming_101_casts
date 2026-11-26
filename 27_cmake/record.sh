#!/bin/bash
# Nimmt die fuenf Demos auf: ./record.sh <zielverzeichnis> [nummer...]
# Die Demos laufen in einer bubblewrap-Sandbox mit /home/student als HOME,
# damit in den Aufnahmen keine privaten Pfade auftauchen.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$(mkdir -p "$1" && cd "$1" && pwd)"; shift
WORK="$(mktemp -d)"
declare -A TITLE=(
  [01_hello]="CMake 1/5: Eine Datei mit CMake bauen"
  [02_buildtypes]="CMake 2/5: Build-Typen und Cache-Variablen"
  [03_libraries]="CMake 3/5: Bibliotheken, PUBLIC und PRIVATE, Shared Libraries"
  [04_ctest]="CMake 4/5: Tests mit CTest"
  [05_fetchcontent]="CMake 5/5: FetchContent"
)
"$HERE/setup.sh" "$WORK/home"
for d in 01_hello 02_buildtypes 03_libraries 04_ctest 05_fetchcontent; do
  if [ $# -gt 0 ] && [[ " $* " != *" ${d%%_*} "* ]]; then continue; fi
  TERM=xterm-256color asciinema rec --overwrite -q --cols 100 --rows 30 -i 3 \
    -t "${TITLE[$d]}" \
    -c "bwrap --dev-bind / / --tmpfs /home --bind $WORK/home /home/student --ro-bind $HERE /home/demo --setenv HOME /home/student --setenv USER student --chdir /home/student bash /home/demo/$d.sh" \
    "$OUT/$d.cast"
  echo "ok: $OUT/$d.cast"
done
rm -rf "$WORK"
