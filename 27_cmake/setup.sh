#!/bin/bash
# Legt die Ausgangsprojekte fuer die fuenf Demos unter $1 an (wird als /home/student eingeblendet).
set -e
H="$1"; rm -rf "$H"; mkdir -p "$H"; cd "$H"

# ---- 1: hello
mkdir -p cmake-hello && cat > cmake-hello/main.cpp <<'X'
#include <iostream>

int main() {
    std::cout << "Hello from CMake!" << std::endl;
    return 0;
}
X
cat > cmake-hello/CMakeLists.txt <<'X'
cmake_minimum_required(VERSION 3.16)
project(Hello VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(hello main.cpp)
target_compile_options(hello PRIVATE -Wall -Wextra)
X

# ---- 2: build types
mkdir -p cmake-buildtypes && cat > cmake-buildtypes/main.cpp <<'X'
#include <cassert>
#include <iostream>
#include <vector>

#ifndef GREETING
#define GREETING "Hello"
#endif

int main() {
#ifdef NDEBUG
    std::cout << "NDEBUG is defined: asserts are removed" << std::endl;
#else
    std::cout << "NDEBUG is not defined: asserts are active" << std::endl;
#endif
    std::cout << GREETING << " from __cplusplus = " << __cplusplus << std::endl;

    std::vector<int> v(1000000, 1);
    long long sum = 0;
    for (int round = 0; round < 200; ++round)
        for (std::size_t i = 0; i < v.size(); ++i)
            sum += v[i] * round;
    std::cout << "sum = " << sum << std::endl;

    int x = 1;
    assert(x == 2 && "x should be 2");
    std::cout << "assert passed or removed" << std::endl;
}
X
cat > cmake-buildtypes/CMakeLists.txt <<'X'
cmake_minimum_required(VERSION 3.16)
project(BuildTypes VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(app main.cpp)
target_compile_options(app PRIVATE -Wall -Wextra)

set(APP_GREETING "Hello" CACHE STRING "Greeting printed by the program")
target_compile_definitions(app PRIVATE GREETING="${APP_GREETING}")
X

# ---- 3: libraries
mkdir -p cmake-libs && cd cmake-libs
mkdir -p geometry/include/geometry geometry/src report/include/report report/src app
cat > geometry/include/geometry/circle.hpp <<'X'
#pragma once

namespace geometry {
double circle_area(double radius);
}  // namespace geometry
X
cat > geometry/src/pi.hpp <<'X'
#pragma once

// Private header: only the library itself includes it.
namespace geometry::detail {
constexpr double pi = 3.14159265358979323846;
}
X
cat > geometry/src/circle.cpp <<'X'
#include "geometry/circle.hpp"
#include "pi.hpp"

namespace geometry {
double circle_area(double radius) {
    return detail::pi * radius * radius;
}
}  // namespace geometry
X
cat > report/include/report/report.hpp <<'X'
#pragma once
#include <string>
#include "geometry/circle.hpp"  // part of the interface of report

namespace report {
std::string describe_circle(double radius);
}  // namespace report
X
cat > report/src/report.cpp <<'X'
#include "report/report.hpp"
#include <sstream>

namespace report {
std::string describe_circle(double radius) {
    std::ostringstream out;
    out << "circle with radius " << radius
        << " has the area " << geometry::circle_area(radius);
    return out.str();
}
}  // namespace report
X
cat > app/main.cpp <<'X'
#include <iostream>
#include "geometry/circle.hpp"
#include "report/report.hpp"

int main() {
    std::cout << report::describe_circle(2.0) << std::endl;
    std::cout << "direct call: " << geometry::circle_area(1.0) << std::endl;
}
X
cat > geometry/CMakeLists.txt <<'X'
add_library(geometry src/circle.cpp)
add_library(geometry::geometry ALIAS geometry)
target_include_directories(geometry
    PUBLIC  include
    PRIVATE src)
X
cat > report/CMakeLists.txt <<'X'
add_library(report src/report.cpp)
add_library(report::report ALIAS report)
target_include_directories(report PUBLIC include)
target_link_libraries(report PUBLIC geometry::geometry)
X
cat > app/CMakeLists.txt <<'X'
add_executable(app main.cpp)
target_link_libraries(app PRIVATE report::report)
X
cat > CMakeLists.txt <<'X'
cmake_minimum_required(VERSION 3.16)
project(LibraryDemo VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(geometry)
add_subdirectory(report)
add_subdirectory(app)

include(GNUInstallDirs)
install(TARGETS geometry report app)
X
cd ..

# ---- 4: ctest
mkdir -p cmake-ctest/src cmake-ctest/tests && cd cmake-ctest
cat > src/numbers.hpp <<'X'
#pragma once

namespace numbers {
// Greatest common divisor of two non-negative numbers.
unsigned gcd(unsigned a, unsigned b);
// True if n is a prime number.
bool is_prime(unsigned n);
}  // namespace numbers
X
cat > src/numbers.cpp <<'X'
#include "numbers.hpp"

namespace numbers {
unsigned gcd(unsigned a, unsigned b) {
    while (b != 0) {
        unsigned r = a % b;
        a = b;
        b = r;
    }
    return a;
}

bool is_prime(unsigned n) {
    if (n < 2) return false;
    for (unsigned d = 2; d * d <= n; ++d)
        if (n % d == 0) return false;
    return true;
}
}  // namespace numbers
X
cat > src/main.cpp <<'X'
#include <cstdlib>
#include <iostream>
#include "numbers.hpp"

int main(int argc, char *argv[]) {
    if (argc != 3) {
        std::cerr << "usage: " << argv[0] << " A B" << std::endl;
        return 2;
    }
    unsigned a = std::strtoul(argv[1], nullptr, 10);
    unsigned b = std::strtoul(argv[2], nullptr, 10);
    std::cout << "gcd = " << numbers::gcd(a, b) << std::endl;
    return 0;
}
X
cat > tests/check.hpp <<'X'
#pragma once
#include <iostream>

// A minimal test helper: report the failed condition and remember it.
static int failures = 0;

#define CHECK(cond)                                                   \
    do {                                                              \
        if (!(cond)) {                                                \
            std::cerr << __FILE__ << ":" << __LINE__                  \
                      << ": CHECK failed: " #cond << std::endl;       \
            ++failures;                                               \
        }                                                             \
    } while (0)
X
cat > tests/test_gcd.cpp <<'X'
#include "check.hpp"
#include "numbers.hpp"

int main() {
    CHECK(numbers::gcd(12, 18) == 6);
    CHECK(numbers::gcd(7, 13) == 1);
    CHECK(numbers::gcd(0, 5) == 5);
    CHECK(numbers::gcd(5, 0) == 5);
    return failures == 0 ? 0 : 1;
}
X
cat > tests/test_prime.cpp <<'X'
#include "check.hpp"
#include "numbers.hpp"

int main() {
    CHECK(!numbers::is_prime(0));
    CHECK(!numbers::is_prime(1));
    CHECK(numbers::is_prime(2));
    CHECK(numbers::is_prime(97));
    CHECK(!numbers::is_prime(91));
    return failures == 0 ? 0 : 1;
}
X
cat > tests/CMakeLists.txt <<'X'
add_executable(test_gcd test_gcd.cpp)
target_link_libraries(test_gcd PRIVATE numbers)
add_test(NAME gcd COMMAND test_gcd)

add_executable(test_prime test_prime.cpp)
target_link_libraries(test_prime PRIVATE numbers)
add_test(NAME prime COMMAND test_prime)

# The command line program is a test subject as well.
add_test(NAME cli_result COMMAND app 12 18)
set_tests_properties(cli_result PROPERTIES PASS_REGULAR_EXPRESSION "gcd = 6")

add_test(NAME cli_without_arguments COMMAND app)
set_tests_properties(cli_without_arguments PROPERTIES WILL_FAIL TRUE)

set_tests_properties(gcd prime PROPERTIES LABELS unit)
set_tests_properties(cli_result cli_without_arguments PROPERTIES LABELS cli)
X
cat > CMakeLists.txt <<'X'
cmake_minimum_required(VERSION 3.16)
project(CTestDemo VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(numbers src/numbers.cpp)
target_include_directories(numbers PUBLIC src)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE numbers)

include(CTest)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
X
cd ..

# ---- 5: FetchContent
mkdir -p fetch_demo/src && cat > fetch_demo/src/main.cpp <<'X'
#include "hello.h"

int main() {
    STEMgraph::printHello();
    return 0;
}
X
cat > fetch_demo/CMakeLists.txt <<'X'
cmake_minimum_required(VERSION 3.16)
project(FetchContentDemo)

include(FetchContent)

FetchContent_Declare(
  stemgraph_cmake_lib
  GIT_REPOSITORY https://github.com/STEMgraph/cmake_test_library.git
  GIT_TAG master
)
FetchContent_MakeAvailable(stemgraph_cmake_lib)

add_executable(fetch_demo src/main.cpp)
target_link_libraries(fetch_demo PRIVATE STEMgraphCMakeLib)
X
