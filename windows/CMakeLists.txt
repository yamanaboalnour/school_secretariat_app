# Project-level configuration.
cmake_minimum_required(VERSION 3.14)

# Allow older third-party CMake projects such as Firebase
# to configure with modern CMake versions.
set(CMAKE_POLICY_VERSION_MINIMUM 3.5 CACHE STRING
    "Minimum CMake policy version for third-party dependencies" FORCE)

project(school_secretariat_app LANGUAGES CXX)

set(BINARY_NAME "school_secretariat_app")

cmake_policy(VERSION 3.14...3.25)