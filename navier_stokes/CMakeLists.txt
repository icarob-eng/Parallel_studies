cmake_minimum_required(VERSION 3.20)

project(
    navier_stokes
    VERSION 1.0
    LANGUAGES Fortran
)

# Fortran standard
set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

find_package(OpenMP REQUIRED)

set(SOURCES
    src/fluid_solver.f90
    src/fluid_io.f90
    src/main.f90
)

add_executable(navier_stokes ${SOURCES})

target_link_libraries(
    navier_stokes
    PRIVATE OpenMP::OpenMP_Fortran
)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")

    target_compile_options(
        navier_stokes
        PRIVATE
        -Wall
        -Wextra
    )

    # Debug-only checks
    target_compile_options(
        navier_stokes
        PRIVATE
        $<$<CONFIG:Debug>:-g>
        $<$<CONFIG:Debug>:-fcheck=all>
        $<$<CONFIG:Debug>:-ffpe-trap=invalid,zero,overflow>
    )

endif()