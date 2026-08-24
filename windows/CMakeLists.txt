# Project-level configuration.
cmake_minimum_required(VERSION 3.14)

# Allow older third-party CMake projects (Firebase C++ SDK)
# to configure correctly with modern CMake versions.
set(CMAKE_POLICY_VERSION_MINIMUM 3.5 CACHE STRING
    "Minimum CMake policy version for third-party dependencies" FORCE)

project(personal_finance_app LANGUAGES CXX)