# Navier-Stokes
A study of parallization and optmization of the Navier-Stokes equation for a pressureless and unforced incompressible fluid. This is a work for the course on Parallel Programing of the Departamento de Engenharia de Computação e Automação da Universidade Federal do Rio Grande do Norte (DCA-UFRN) for the semester 2026.2.

## Building
### Compiling directly with `gfortran`
Compiling the modules:
```bash
gfortran -fopenmp -g -fcheck=all -ffpe-trap=invalid,zero,overflow -c src/fluid_io.f90 src/fluid_solver.f90
```
Compiling the main program:
```bash
gfortran -fopenmp -g -fcheck=all -ffpe-trap=invalid,zero,overflow main.f90 src/fluid_io.o src/fluid_solver.o -o src/navier_stokes
```
Running the program:
```bash
./build/debug/navier_stokes 50 50 10000 1.0 1.0 0.0001 0.01
```
### Compiling with `cmake`
Generating the build files:
```bash
cmake --preset debug
```
Building the project:
```bash
cmake --build --preset debug
```
Running the program:
```bash
./build/debug/navier_stokes 50 50 10000 1.0 1.0 0.0001 0.01
```
## Simulation parameters input
The data is passed directly in the `main.f90` file. The grid and time size and scale, as well as the viscosty parameter are all passed as CLI arguments to the program. The velocity field is initialized with a custom `init_field` subroutine, which can be overwriten and the program should be recompiled. Additional parameter variables are:
```fortran
integer(c_int), parameter   :: save_steps = 500  ! save each `save_steps` steps
integer(c_int), parameter   :: stability_steps = 1000  ! check stabilty each `stability_steps` steps
character(len=*), parameter :: OUTPUT = "results/velocity.dat"
```
## Output visualizer
Consult the `fluid_io.f90` module for the `.dat` output file format. There's a Python script for visualizing the data as a `.gif`. Just run
```bash
python plot.py
```