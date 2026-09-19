module fluid_io

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
    !! program nx ny nsteps lx ly dt nu
    !! \endcode
    !!
    !! For example:
    !!
    !! \code
    !! $ ./navier_stokes 50 50 1000 1.0 1.0 0.0001 0.01
    !! \endcode
    !!
    !! @param[out] nx     Number of grid points in x.
    !! @param[out] ny     Number of grid points in y.
    !! @param[out] nsteps Number of time steps of the simulation.
    !! @param[out] lx     Size of the complete grid x axis.
    !! @param[out] ly     Size of the complete grid y axis.
    !! @param[out] dt     Scale of 
    !! @param[out] nu     Viscosiy parameter.
    subroutine read_params(nx, ny, nsteps, lx, ly, dt, nu)
        ! Grid size input
        integer(c_int), intent(out) :: nx  ! = 50
        integer(c_int), intent(out) :: ny  ! = 50
        integer(c_int), intent(out) :: nsteps  ! = 10000
        ! Grid scale input
        real(c_double), intent(out) :: lx  ! = 1.0_c_double
        real(c_double), intent(out) :: ly  ! = 1.0_c_double
        real(c_double), intent(out) :: dt  ! = 0.0001_c_double
        ! Viscosity value input
        real(c_double), intent(out) :: nu  ! = 0.01_c_double
        integer(c_int)              :: status ! argc
        character(len=64)           :: argv

        if (command_argument_count() /= 7) then
            write(*,*) "Usage:"
            write(*,*) "./navier_stokes nx ny nsteps lx ly dt nu "
            error stop "Invalid number of arguments."
        end if

        call get_command_argument(1, argv, status=status)
        if (status /= 0) error stop "Could not read nx."
        read(argv, *, iostat=status) nx
        if (status /= 0) error stop "Invalid value for nx."

        call get_command_argument(2, argv, status=status)
        if (status /= 0) error stop "Could not read ny."
        read(argv, *, iostat=status) ny
        if (status /= 0) error stop "Invalid value for ny."

        call get_command_argument(3, argv, status=status)
        if (status /= 0) error stop "Could not read nsteps."
        read(argv, *, iostat=status) nsteps
        if (status /= 0) error stop "Invalid value for nsteps."

        call get_command_argument(4, argv, status=status)
        if (status /= 0) error stop "Could not read lx."
        read(argv, *, iostat=status) lx
        if (status /= 0) error stop "Invalid value for lx."

        call get_command_argument(5, argv, status=status)
        if (status /= 0) error stop "Could not read ly."
        read(argv, *, iostat=status) ly
        if (status /= 0) error stop "Invalid value for ly."

        call get_command_argument(6, argv, status=status)
        if (status /= 0) error stop "Could not read dt."
        read(argv, *, iostat=status) dt
        if (status /= 0) error stop "Invalid value for dt."

        call get_command_argument(7, argv, status=status)
        if (status /= 0) error stop "Could not read nu."
        read(argv, *, iostat=status) nu
        if (status /= 0) error stop "Invalid value for nu."
    end subroutine read_params


    !> Initis a new save file with header:
    !!
    !! \code
    !! # t              x              y              u              v
    !! \endcode
    !!
    !! @param[in] filename Output file name.
    subroutine init_file(filename)
        character(len=*), intent(in) :: filename

        open(unit=10, file=filename, status="replace", action="write")
        write(10, *) "# t              x              y              u              v"
        close(10)
    end subroutine init_file

    !> Append velocid field step to a text file.
    !!
    !! Each line contains the position and velocity components:
    !!
    !! \code
    !! t  x  y  u  v
    !! \endcode
    !!
    !! @param[in] filename Output file name.
    !! @param[in] u        x-component of velocity.
    !! @param[in] v        y-component of velocity.
    !! @param[in] nx       Number of grid points in x.
    !! @param[in] ny       Number of grid points in y.
    !! @param[in] dx       Grid spacing in x.
    !! @param[in] dy       Grid spacing in y.
    !! @param[in] t        Current step time.
    subroutine save_step(filename, u, v, nx, ny, dx, dy, t)
        character(len=*), intent(in) :: filename
        integer(c_int), intent(in) :: nx, ny
        real(c_double), intent(in) :: u(nx,ny), v(nx,ny)
        real(c_double), intent(in) :: dx, dy, t
        integer(c_int) :: i, j

        open(unit=10, file=filename, status="old", position="append", action="write")

        do j = 1, ny
            do i = 1, nx
                write(10,'(5ES15.6)') &
                    t, &
                    real(i - 1, c_double) * dx, &
                    real(j - 1, c_double) * dy, &
                    u(i,j), &
                    v(i,j)
            end do
            write(10,*)
        end do
        close(10)

    end subroutine save_step

end module fluid_io