# Heat diffusion
A study of parallization and optmization of the linear heat diffusion equation in a bar. This is a work for the course on Parallel Programing of the Departamento de Engenharia de Computação e Automação da Universidade Federal do Rio Grande do Norte (DCA-UFRN) for the semester 2026.2.


## Building
### Compiling directly with `gfortran`
Compiling the modules:
```bash
gfortran -fopenmp -g -fcheck=all -ffpe-trap=invalid,zero,overflow -c src/io.f90 src/temp_calc.f90
```
Compiling the main program:
```bash
gfortran -fopenmp -g -fcheck=all -ffpe-trap=invalid,zero,overflow main.f90 src/io.o src/temp_calc.o -o build/debug/heat_diff
```
Running the program:
```bash
./build/debug/heat_diff 100 100000 1.0 0.01 0.001
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
./build/debug/heat_diff 100 100000 1.0 0.01 0.001
```

## Simulation parameters input
The data is passed directly in the `main.f90` file. The grid and time size and scale, as well as the thermal condutivity are all passed as CLI arguments to the program. The initial conditions are definend as `Temp=0` for all cells, which can be overwriten and the program should be recompiled. Additional parameter variables are:
```fortran
integer(c_int), parameter   :: save_steps = 500 ! save each `save_steps` steps
character(len=*), parameter :: OUTPUT = "results/temperature.dat"
```
## Output visualizer
Consult the `io.f90` module for the `.dat` output file format. There's a Python script for visualizing the data as a `.png`. Just run
```bash
python plot.py
```