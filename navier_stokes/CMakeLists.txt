cmake_minimum_required(VERSION 3.20)

project(
        navier_stokes
        VERSION 1.0
        LANGUAGES Fortran
)

# Fortran standard
set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    add_compile_options(
            -fopenmp
            -Wall
            -Wextra
            -g
            -fcheck=all
            -ffpe-trap=invalid,zero,overflow
    )
endif()

# Source files
set(SOURCES
        src/fluid_solver.f90
        src/fluid_io.f90
        src/main.f90
)

# Executable
add_executable(navier_stokes ${SOURCES})
