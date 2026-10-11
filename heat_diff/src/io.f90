module io
    use iso_c_binding, only: c_double, c_int
    implicit none

    private
    public :: init_file, save_step, read_params

contains
    !> Read simulation parameters from command-line arguments.
    !!
    !! The expected command-line format is:
    !!
    !! \code
    !! program ncells nsteps length dt alpha
    !! \endcode
    !!
    !! For example:
    !!
    !! \code
    !! $ ./heat_diff 100 100000 1.0 0.01 0.001
    !! \endcode
    !!
    !! @param[out] ncells Number of grid points along the bar.
    !! @param[out] nsteps Number of time steps of the simulation.
    !! @param[out] length Total size of the bar x axis.
    !! @param[out] dt     Scale of a time step.
    !! @param[out] alpha  Heat diffusion constant.
    subroutine read_params(ncells, nsteps, length, dt, alpha)
        ! Grid size input
        integer(c_int), intent(out) :: ncells  ! = 100
        integer(c_int), intent(out) :: nsteps  ! = 100000
        ! Grid scale input
        real(c_double), intent(out) :: length  ! = 1.0_c_double
        real(c_double), intent(out) :: dt      ! = 0.01_c_double
        ! Viscosity value input
        real(c_double), intent(out) :: alpha  ! = 0.001_c_double
        integer(c_int)              :: status ! argc
        character(len=64)           :: argv

        if (command_argument_count() /= 5) then
            write(*,*) "Usage:"
            write(*,*) "./heat_diff ncells nsteps length dt alpha "
            error stop "Invalid number of arguments."
        end if

        call get_command_argument(1, argv, status=status)
        if (status /= 0) error stop "Could not read ncells."
        read(argv, *, iostat=status) ncells
        if (status /= 0) error stop "Invalid value for ncells."

        call get_command_argument(2, argv, status=status)
        if (status /= 0) error stop "Could not read nsteps."
        read(argv, *, iostat=status) nsteps
        if (status /= 0) error stop "Invalid value for nsteps."

        call get_command_argument(3, argv, status=status)
        if (status /= 0) error stop "Could not read length."
        read(argv, *, iostat=status) length
        if (status /= 0) error stop "Invalid value for length."

        call get_command_argument(4, argv, status=status)
        if (status /= 0) error stop "Could not read dt."
        read(argv, *, iostat=status) dt
        if (status /= 0) error stop "Invalid value for dt."

        call get_command_argument(5, argv, status=status)
        if (status /= 0) error stop "Could not read alpha."
        read(argv, *, iostat=status) alpha
        if (status /= 0) error stop "Invalid value for alpha."
    end subroutine read_params

    !> Initis a new save file with header:
    !!
    !! \code
    !! # t              x              Temp
    !! \endcode
    !!
    !! @param[in] filename Output file name.
    subroutine init_file(filename)
        character(len=*), intent(in) :: filename

        open(unit=10, file=filename, status="replace", action="write")
        write(10, *) "# t              x              Temp"
        close(10)
    end subroutine init_file

    !> Append heat diffusion step to a text file.
    !!
    !! Each line contains the position temperature components:
    !!
    !! \code
    !! t  x  Temp
    !! \endcode
    !!
    !! @param[in] filename Output file name.
    !! @param[in] ncells   Number of grid points along the bar.
    !! @param[in] length   Total size of the bar x axis.
    !! @param[in] Temp     vector with temperature of each cell.
    !! @param[in] t        Current time.
    subroutine save_step(filename, ncells, length, Temp, t)
        character(len=*), intent(in) :: filename
        integer(c_int), intent(in) :: ncells
        real(c_double), intent(in) :: Temp(0: ncells+1)
        real(c_double), intent(in) :: t, length
        integer(c_int) :: i

        open(unit=10, file=filename, status="old", position="append", action="write")

        do i = 0, ncells+1
            write(10,'(5ES15.6)') &
                t, &
                real(i - 1, c_double) * length/ncells, &
                Temp(i)
        end do
        write(10,*)
        close(10)

    end subroutine save_step
end module