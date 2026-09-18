program navier_stokes

    use iso_c_binding, only: c_double, c_int

    use fluid_solver
    use fluid_io

    implicit none
    integer(c_int) :: nx, ny, nsteps
    real(c_double) :: lx, ly, dt, nu
    integer(c_int), parameter   :: save_steps = 500  ! save each `save_steps` steps
    integer(c_int), parameter   :: stability_steps = 1000  ! check stabilty each `stability_steps` steps
    character(len=*), parameter :: OUTPUT = "results/velocity.dat"

    real(c_double) :: dx, dy, stability, error, t, t_lastsave
    real(c_double), allocatable :: u(:,:), v(:,:), unext(:,:), vnext(:,:), times(:)
    integer(c_int) :: i_t

    call read_params(nx, ny, nsteps, lx, ly, dt, nu)
    call init_file(OUTPUT)

    ! Grid spacing.
    dx = lx / real(nx - 1, c_double)
    dy = ly / real(ny - 1, c_double)

    allocate(u(nx,ny))
    allocate(v(nx,ny))
    allocate(unext(nx,ny))
    allocate(vnext(nx,ny))
    allocate(times(nsteps))

    ! call init_field_uniform(u, v)
    call init_field_gaussian(u, v)

    stability = check_stability(nu, dt, dx, dy)

    write(*,'(A,F12.6)') "Stability parameter = ", stability

    if (stability > 0.5_c_double) then
        write(*,*) "ERROR: unstable time step."
        stop 1
    end if

    ! Time integration.
    t = 0
    t_lastsave = 0
    do i_t = 1, nsteps
        call time_step(u, v, unext, vnext, nx, ny, dx, dy, nu, dt, t)

        u = unext
        v = vnext

        ! Stability check
        if (mod(i_t, stability_steps) == 0) then
            error = check_error(u, nx, ny)

            write(*,'(A,I6,A,ES14.6)') "step = ", i_t, " max error = ", error
        end if

        ! Save step
        if (mod(i_t, save_steps) == 0) then
            call save_step(OUTPUT, u, v, nx, ny, dx, dy, t)
            t_lastsave = t
        end if
    end do

    ! Save final state.
    if (t /= t_lastsave) then
        call save_step(OUTPUT, u, v, nx, ny, dx, dy, t)
    end if

    ! Free memory.
    deallocate(u, v, unext, vnext, times)

contains

    !> init the velocity field with a constant velocity.
    !!
    !! This works as an input function. Inherits the global values of nx and ny.
    !!
    !! @param[out] u_  x-component of the velocity field.
    !! @param[out] v_  y-component of the velocity field.
    subroutine init_field_uniform(u_, v_)
        real(c_double), intent(out) :: u_(nx,ny), v_(nx,ny)

        u_ = 1.0_c_double
        v_ = 0.0_c_double
    end subroutine init_field_uniform

    subroutine init_field_gaussian(u_, v_)
        real(c_double), intent(out) :: u_(nx,ny), v_(nx,ny)

        integer :: i, j
        real(c_double) :: xi, yj
        real(c_double) :: x0, y0, sigma, u0

        u0 = 1.0d0
        x0 = lx / 2.0d0
        y0 = ly / 2.0d0
        sigma = 0.1d0 * min(lx, ly)

        do i = 1, nx
            xi = (i - 1) * lx / (nx - 1)

            do j = 1, ny
                yj = (j - 1) * ly / (ny - 1)

                u_(i,j) = u0 * exp( &
                    -((xi-x0)**2 + (yj-y0)**2) / (2.0d0*sigma**2) &
                )

                v_(i,j) = 0.0d0
            end do
        end do
    end subroutine init_field_gaussian

end program navier_stokes