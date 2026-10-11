program heat_diff
    use iso_c_binding, only: c_double, c_int
    use temp_calc
    use io
    implicit none
    integer(c_int)  :: ncells, nsteps
    real(c_double)  :: length, dt, alpha
    integer(c_int), parameter   :: save_steps = 500 ! save each `save_steps` steps
    character(len=*), parameter :: OUTPUT = "results/temperature.dat"

    real(c_double) :: r
    real(c_double), allocatable :: Temp(:), next_Temp(:)
    integer(c_int) :: i_t

    call read_params(ncells, nsteps, length, dt, alpha)
    r = alpha * dt / (length/ncells)**2

    if (r > 0.5) then
        print *, 'r =', r
        error stop 'Unstable system. r > 0.5'
    end if
    call init_file(OUTPUT)

    allocate(Temp(0:ncells + 1))
    Temp = 0
    call enforce_bounds(Temp, ncells)
    allocate(next_Temp(0:ncells + 1))

    do i_t=1, nsteps
        call iter_temp(Temp, next_Temp, ncells, r)
        call enforce_bounds(next_Temp, ncells)
        Temp = next_Temp

        if (mod(i_t, save_steps) == 0) then
            call save_step(OUTPUT, ncells, length, Temp, i_t*dt)
        end if
    end do

    ! last save
    call save_step(OUTPUT, ncells, length, Temp, i_t*dt)
contains
    subroutine enforce_bounds(vec, n)
        real(c_double), parameter     :: lower_bound = 0, higher_bound = 100
        integer(c_int), intent(in)    :: n
        real(c_double), intent(inout) :: vec(0:n+1)

        vec(0) = lower_bound
        vec(ncells+1) = higher_bound
    end subroutine
end program