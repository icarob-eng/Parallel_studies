module fluid_solver

    use iso_c_binding, only: c_double, c_int

    implicit none

    private

    public :: check_stability, time_step, check_error

contains
    !> Compute the stability parameter for the explicit scheme.
    !!
    !! For the two-dimensional diffusion equation, the explicit
    !! forward-Euler scheme requires
    !!
    !! \f[
    !! \nu \Delta t
    !! \left(
    !! \frac{1}{\Delta x^2}
    !! +
    !! \frac{1}{\Delta y^2}
    !! \right)
    !! \leq \frac{1}{2}.
    !!
    !! @param[in] nu Kinematic viscosity.
    !! @param[in] dt Time step.
    !! @param[in] dx Grid spacing in the x direction.
    !! @param[in] dy Grid spacing in the y direction.
    !!
    !! @return The stability parameter.
    function check_stability(nu, dt, dx, dy) result(s)
        real(c_double), intent(in) :: nu, dt, dx, dy
        real(c_double) :: s

        s = nu * dt * &
            (1.0_c_double / dx**2 + &
             1.0_c_double / dy**2)

    end function check_stability


    !> Perform one time step of viscous evolution.
    !!
    !! The equations being solved are
    !!
    !! \f[
    !! \frac{\partial u}{\partial t}
    !! =
    !! \nu \nabla^2 u,
    !! \f]
    !!
    !! \f[
    !! \frac{\partial v}{\partial t}
    !! =
    !! \nu \nabla^2 v.
    !! \f]
    !!
    !! The spatial derivatives are discretized using a second-order
    !! central finite difference and time evolution uses forward Euler.
    !!
    !! Periodic boundary conditions are used in both directions.
    !!
    !! @param[in]  u     Current x-component of velocity.
    !! @param[in]  v     Current y-component of velocity.
    !! @param[out] unext Next x-component of velocity.
    !! @param[out] vnext Next y-component of velocity.
    !! @param[in]  nx    Number of grid points in the x direction.
    !! @param[in]  ny    Number of grid points in the y direction.
    !! @param[in]  dx    Grid spacing in the x direction.
    !! @param[in]  dy    Grid spacing in the y direction.
    !! @param[in]  nu    Kinematic viscosity.
    !! @param[in]  dt    Time step.
    !! @param[inout] t   Current step time.
    subroutine time_step(u, v, unext, vnext, nx, ny, dx, dy, nu, dt, t)
        integer(c_int), intent(in)  :: nx, ny
        real(c_double), intent(in)  :: u(nx,ny),     v(nx,ny)
        real(c_double), intent(out) :: unext(nx,ny), vnext(nx,ny)
        real(c_double), intent(in)  :: dx, dy, nu, dt
        real(c_double), intent(inout)  :: t
        integer(c_int) :: i, j, ip, im, jp, jm
        real(c_double) :: lap_u, lap_v

        do i = 1, nx

            ! Periodic neighbors in x (mod makes the hole grid periodic)
            ip = mod(i, nx) + 1
            im = mod(i - 2 + nx, nx) + 1

            do j = 1, ny

                ! Periodic neighbors in y.
                jp = mod(j, ny) + 1
                jm = mod(j - 2 + ny, ny) + 1

                ! Laplacian of u.
                lap_u = &
                    (u(ip,j) - 2.0_c_double*u(i,j) + u(im,j)) / dx**2 &
                    + &
                    (u(i,jp) - 2.0_c_double*u(i,j) + u(i,jm)) / dy**2

                ! Laplacian of v.
                lap_v = &
                    (v(ip,j) - 2.0_c_double*v(i,j) + v(im,j)) / dx**2 &
                    + &
                    (v(i,jp) - 2.0_c_double*v(i,j) + v(i,jm)) / dy**2

                ! Forward Euler.
                unext(i,j) = u(i,j) + nu * dt * lap_u
                vnext(i,j) = v(i,j) + nu * dt * lap_v
            end do
        end do
        t = t + dt
    end subroutine time_step


    !> Compute the maximum deviation from a constant velocity field.
    !!
    !! This function is useful for verifying that a uniform velocity
    !! field remains stationary under viscous evolution.
    !!
    !! For the default initial condition, the expected result is
    !! approximately zero up to floating-point round-off.
    !!
    !! @param[in] u  x-component of the velocity field.
    !! @param[in] nx Number of grid points in the x direction.
    !! @param[in] ny Number of grid points in the y direction.
    !!
    !! @return Maximum value of \f$|u-1|\f$.
    function check_error(u, nx, ny) result(error)
        integer(c_int), intent(in) :: nx, ny
        real(c_double), intent(in) :: u(nx,ny)
        real(c_double) :: error

        error = maxval(abs(u - 1.0_c_double))

    end function check_error

end module fluid_solver