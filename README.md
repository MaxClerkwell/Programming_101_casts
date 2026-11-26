# Programming 101: Terminalaufzeichnungen

asciinema-Aufzeichnungen zur Vorlesung „Programmierung & Objektorientierung“.
Jede Aufzeichnung ist eine `.cast`-Datei und lässt sich im Terminal abspielen:

```bash
sudo apt install asciinema        # einmalig
asciinema play 27_cmake/01_hello.cast
```

Im Player hält die Leertaste an, `.` geht im angehaltenen Zustand schrittweise weiter.

## Kapitel 27: Buildsystemautomation mit CMake

| Datei | Thema | Dauer | Übung |
|---|---|---|---|
| [`01_hello.cast`](27_cmake/01_hello.cast) | Eine Datei mit CMake bauen: konfigurieren, bauen, Build-Verzeichnis | 65 s | [STEMgraph/3d0ad147](https://github.com/STEMgraph/3d0ad147-62b6-44c1-8263-ad4d8340422a) |
| [`02_buildtypes.cast`](27_cmake/02_buildtypes.cast) | Build-Typen Debug und Release, Compiler-Zeile, Cache-Variablen | 110 s | [STEMgraph/866ad588](https://github.com/STEMgraph/866ad588-53ff-411b-ba93-801d73ec0311) |
| [`03_libraries.cast`](27_cmake/03_libraries.cast) | Bibliotheken, `PUBLIC` und `PRIVATE`, Shared Libraries, Installation | 145 s | [STEMgraph/938ab1bf](https://github.com/STEMgraph/938ab1bf-f755-44bf-a444-7f34a763f7a1) |
| [`04_ctest.cast`](27_cmake/04_ctest.cast) | Tests mit CTest: Fehlschlag, Labels, Timeout | 112 s | [STEMgraph/0075452c](https://github.com/STEMgraph/0075452c-39b1-45e3-9e01-2a7de3c027c9) |
| [`05_fetchcontent.cast`](27_cmake/05_fetchcontent.cast) | `FetchContent`: eine Bibliothek aus dem Netz einbinden | 73 s | [STEMgraph/76bd92a3](https://github.com/STEMgraph/76bd92a3-ba4d-4048-aa73-a0be33492c58) |

Aufgenommen mit cmake 4.3.4 und g++ 16.2. Mit anderen Versionen weichen die
Ausgaben leicht ab, zum Beispiel die Compiler-Zeile bei `--verbose`.

## Selbst aufnehmen

Die Aufzeichnungen sind geskriptet. Die Skripte liegen neben den `.cast`-Dateien:

- `setup.sh` legt die Ausgangsprojekte an,
- `01_hello.sh` bis `05_fetchcontent.sh` enthalten die Befehle der jeweiligen Demo,
- `record.sh` nimmt auf: `./record.sh .` für alle, `./record.sh . 03` für eine.

Benötigt werden `asciinema`, `bwrap` (bubblewrap), `tree`, `cmake`, `make`, `g++`
und für die fünfte Aufzeichnung eine Netzverbindung.
