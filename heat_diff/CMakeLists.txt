cmake_minimum_required(VERSION 3.20)

project(
    heat_diff
    VERSION 1.0
    LANGUAGES Fortran
)

# Fortran standard
set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

find_package(OpenMP REQUIRED)

set(SOURCES
    src/temp_calc.f90
    src/io.f90
    src/main.f90
)

add_executable(heat_diff ${SOURCES})

target_link_libraries(
    heat_diff
    # PRIVATE OpenMP::OpenMP_Fortran
)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")

    target_compile_options(
        heat_diff
        PRIVATE
        -Wall
        -Wextra
    )

    # Debug-only checks
    target_compile_options(
        heat_diff
        PRIVATE
        $<$<CONFIG:Debug>:-g>
        $<$<CONFIG:Debug>:-fcheck=all>
        $<$<CONFIG:Debug>:-ffpe-trap=invalid,zero,overflow>
    )

endif()