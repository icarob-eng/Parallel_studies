cmake_minimum_required(VERSION 3.20)

# MPI Fortran compiler wrapper
set(CMAKE_Fortran_COMPILER mpifort)

project(
    heat_diff
    VERSION 1.0
    LANGUAGES Fortran
)

set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

find_package(MPI REQUIRED COMPONENTS Fortran)
find_package(OpenMP REQUIRED)

set(SOURCES
    src/temp_calc.f90
    src/io.f90
    src/main.f90
)

add_executable(heat_diff ${SOURCES})

target_link_libraries(
    heat_diff
    PRIVATE MPI::MPI_Fortran
    # PRIVATE OpenMP::OpenMP_Fortran
)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")

    target_compile_options(
        heat_diff
        PRIVATE
        -Wall
        -Wextra
        $<$<CONFIG:Debug>:-g>
        $<$<CONFIG:Debug>:-fcheck=all>
        $<$<CONFIG:Debug>:-ffpe-trap=invalid,zero,overflow>
    )

endif()