module temp_calc
    use iso_c_binding, only: c_double, c_int
implicit none

    private
    public :: iter_temp
contains
    subroutine iter_temp(Temp, next_Temp, ncells, r)
        integer, intent(in) :: ncells
        real(c_double), intent(in)  :: Temp(0:ncells+1), r
        real(c_double), intent(out) :: next_Temp(0:ncells+1)
        integer :: i

        do i=1, ncells
            next_Temp(i) = Temp(i) + r * (Temp(i+1) - 2*Temp(i) + Temp(i-1))
        end do
    end subroutine
end module