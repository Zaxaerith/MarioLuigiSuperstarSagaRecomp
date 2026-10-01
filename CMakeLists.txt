# ---------------------------------------------------------------------------
# MarioLuigiSuperstarSagaRecomp — host executable.
#
# Shape (same thin host as the working sibling integrations):
#
#   GBARECOMP_ROOT (shared, read-only)   framework source
#   generated/cart                       cartridge translation (tools/regen.ps1)
#   generated/bios                       BIOS translation     (tools/regen.ps1)
#   src/main.cpp                         entire game-specific host layer
#
# Configure (MinGW + Ninja):
#   cmake -S . -B build/host -G Ninja -DCMAKE_BUILD_TYPE=Release ^
#         -DCMAKE_C_COMPILER=C:/MYAPPLY/mingw64/bin/gcc.exe ^
#         -DCMAKE_CXX_COMPILER=C:/MYAPPLY/mingw64/bin/g++.exe
#   cmake --build build/host
# ---------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)
project(MarioLuigiSuperstarSagaRecomp C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()

# ---------------------------------------------------------- framework source
# Prefer a local pinned snapshot (release posture); fall back to the shared
# read-only checkout.
set(_gba_framework_candidates
    "${CMAKE_CURRENT_SOURCE_DIR}/reference/gbarecomp"
    "${CMAKE_CURRENT_SOURCE_DIR}/../gbarecomp-main"
    "$ENV{GBARECOMP_ROOT}"
)
set(GBARECOMP_ROOT "" CACHE PATH "Framework source checkout")
if(NOT GBARECOMP_ROOT)
    foreach(_cand IN LISTS _gba_framework_candidates)
        if(_cand AND EXISTS "${_cand}/CMakeLists.txt")
            set(GBARECOMP_ROOT "${_cand}" CACHE PATH "Framework source checkout" FORCE)
            break()
        endif()
    endforeach()
endif()
if(NOT EXISTS "${GBARECOMP_ROOT}/CMakeLists.txt")
    message(FATAL_ERROR
        "Missing framework at GBARECOMP_ROOT (tried reference/gbarecomp and ../gbarecomp-main).")
endif()
message(STATUS "MarioLuigiSuperstarSagaRecomp: framework ${GBARECOMP_ROOT}")

# toml++ headers: reuse an existing build if present, else let FetchContent run.
set(_gba_toml_candidates
    "${CMAKE_CURRENT_SOURCE_DIR}/.deps/tomlplusplus"
    "${CMAKE_CURRENT_SOURCE_DIR}/../gbarecomp-main/build-vs/_deps/tomlplusplus-src"
    "${CMAKE_CURRENT_SOURCE_DIR}/../gbarecomp-main/build-mingw/_deps/tomlplusplus-src"
)
set(GBARECOMP_TOMLPP_INCLUDE_DIR "" CACHE PATH "toml++ headers")
if(NOT GBARECOMP_TOMLPP_INCLUDE_DIR)
    foreach(_cand IN LISTS _gba_toml_candidates)
        if(_cand AND EXISTS "${_cand}/toml.hpp")
            set(GBARECOMP_TOMLPP_INCLUDE_DIR "${_cand}" CACHE PATH "toml++ headers" FORCE)
            break()
        endif()
    endforeach()
endif()
if(GBARECOMP_TOMLPP_INCLUDE_DIR)
    message(STATUS "MarioLuigiSuperstarSagaRecomp: toml++ ${GBARECOMP_TOMLPP_INCLUDE_DIR}")
endif()

set(GBARECOMP_GENERATED_BIOS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/generated/bios"
    CACHE PATH "Local BIOS translation")

# ----------------------------------------------------------------- generated
file(GLOB CART_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/generated/cart/*.cpp")
if(NOT CART_SOURCES)
    message(FATAL_ERROR
        "No cartridge translation in generated/cart. Run tools/regen.ps1 first.")
endif()
if(NOT EXISTS "${GBARECOMP_GENERATED_BIOS_DIR}/bios_recompiled.cpp")
    message(FATAL_ERROR
        "No BIOS translation in ${GBARECOMP_GENERATED_BIOS_DIR}. Run tools/regen.ps1 first.")
endif()

# ------------------------------------------------------------------------ SDL2
set(_gba_sdl2_candidates
    "${GBARECOMP_MINGW_PREFIX_UNIX}"
    "$ENV{SDL2_ROOT}"
    "${CMAKE_CURRENT_SOURCE_DIR}/.deps/sdl2/x86_64-w64-mingw32"
    "${CMAKE_CURRENT_SOURCE_DIR}/../_sdl2/SDL2-2.32.8/x86_64-w64-mingw32"
    "C:/msys64/mingw64"
)
file(GLOB _gba_sdl2_siblings "${CMAKE_CURRENT_SOURCE_DIR}/../_sdl2/SDL2-*/x86_64-w64-mingw32")
list(APPEND _gba_sdl2_candidates ${_gba_sdl2_siblings})
set(_gba_sdl2_root "")
foreach(_cand IN LISTS _gba_sdl2_candidates)
    if(_cand AND EXISTS "${_cand}/include/SDL2/SDL.h")
        set(_gba_sdl2_root "${_cand}")
        break()
    endif()
endforeach()

if(NOT GBARECOMP_MINGW_PREFIX_UNIX)
    if(_gba_sdl2_root)
        set(GBARECOMP_MINGW_PREFIX_UNIX "${_gba_sdl2_root}" CACHE PATH
            "SDK root used by the framework to locate SDL2" FORCE)
    else()
        message(WARNING
            "No SDL2 SDK found (set -DSDL2_ROOT=<...>/x86_64-w64-mingw32). "
            "host_window will compile as a no-op stub.")
    endif()
endif()
if(_gba_sdl2_root)
    message(STATUS "MarioLuigiSuperstarSagaRecomp: SDL2 SDK root ${_gba_sdl2_root}")
endif()

if(NOT GBARECOMP_MINGW_RUNTIME_BIN AND MINGW)
    get_filename_component(_gba_mingw_bin "${CMAKE_CXX_COMPILER}" DIRECTORY)
    set(GBARECOMP_MINGW_RUNTIME_BIN "${_gba_mingw_bin}" CACHE PATH
        "Directory holding libgcc_s_seh-1.dll / libstdc++-6.dll / libwinpthread-1.dll")
endif()

# ------------------------------------------------------------------- framework
add_subdirectory("${GBARECOMP_ROOT}" framework EXCLUDE_FROM_ALL)

# ------------------------------------------------------------------ executable
add_executable(MarioLuigiSuperstarSagaRecomp src/main.cpp ${CART_SOURCES})
target_link_gbarecomp_runtime_stack(MarioLuigiSuperstarSagaRecomp)
if(MINGW)
    target_link_options(MarioLuigiSuperstarSagaRecomp PRIVATE "-Wl,--stack,67108864")
endif()

set(_gba_shards ${CART_SOURCES})
list(FILTER _gba_shards INCLUDE REGEX "/recompiled_[0-9]+\\.cpp$")
if(_gba_shards)
    if(MSVC)
        set_source_files_properties(${_gba_shards} PROPERTIES COMPILE_OPTIONS "/O1")
    else()
        set_source_files_properties(${_gba_shards} PROPERTIES COMPILE_OPTIONS "-O1;-g0")
    endif()
endif()

gbarecomp_stage_mingw_runtime(MarioLuigiSuperstarSagaRecomp)

if(_gba_sdl2_root AND EXISTS "${_gba_sdl2_root}/bin/SDL2.dll")
    add_custom_command(TARGET MarioLuigiSuperstarSagaRecomp POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${_gba_sdl2_root}/bin/SDL2.dll"
            "$<TARGET_FILE_DIR:MarioLuigiSuperstarSagaRecomp>/SDL2.dll"
        VERBATIM)
endif()

list(LENGTH _gba_shards _gba_shard_count)
message(STATUS "MarioLuigiSuperstarSagaRecomp: cartridge shards = ${_gba_shard_count}")
