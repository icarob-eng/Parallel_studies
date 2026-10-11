program heat_diff
    use iso_c_binding, only: c_double, c_int
    use temp_calc
    use io

    use mpi_f08
    implicit none
    integer(c_int) :: rank, num_proc, proc_cells, master_cells
    type(MPI_Status)    :: mpistatus
    real(c_double) :: Wtime

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

    call MPI_Init()
    call MPI_Comm_size(MPI_COMM_WORLD, num_proc)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank)

    if (mod(ncells, num_proc) == 0) then
        ! equal partition
        proc_cells = ncells/num_proc
        master_cells = proc_cells
    else
        ! master does different work
        proc_cells = ncells/(num_proc-1)

        ! lazy fix :)
        if (ncells < num_proc - 1) error stop 'Too many MPI processes'

        ! takes what work is left
        master_cells = ncells - proc_cells*(num_proc-1)
    end if

    ! print *, '------------'
    ! print *, 'ncells =', ncells
    ! print *, 'num_proc =', num_proc
    ! print *, 'cells per proc =', proc_cells
    ! print *, 'cells in master =', master_cells
    
    if (rank == 0) then
        print *, 'Interval allocation: Rank, start, stop'
        do i_t=1, num_proc-1
            print *, i_t, get_interv_start(i_t), get_intrv_stop(i_t)
        end do
        print *, 0, proc_cells*(num_proc-1)+1, ncells

        ! initialize things
        call init_file(OUTPUT)
        
        allocate(Temp(0:ncells + 1))
        Temp = 0
        call enforce_bounds(Temp, ncells)
        allocate(next_Temp(ncells))
    else
        ! local copies of Temp are just a subsection of the whole length
        allocate(Temp(0:proc_cells + 1))
        Temp = 0
        allocate(next_Temp(proc_cells))
    end if
        
    do i_t=1, nsteps
        if (rank == 0) then
            call send_intervals()
            call iter_temp( &  ! actual boundary: proc_cells*(num_proc-1)+1:ncells
                            Temp(proc_cells*(num_proc-1):ncells+1), & 
                            next_Temp(proc_cells*(num_proc-1)+1:ncells), &
                            master_cells, r)
            call recv_intervals()
            
            Temp(1:ncells) = next_Temp  ! does not update boundary values
            call enforce_bounds(Temp, ncells)
            
            if (mod(i_t, save_steps) == 0) then
                call save_step(OUTPUT, ncells, length, Temp, i_t*dt)
            end if
        else
            ! proc_cells+2 includes padding:
            call MPI_Recv(Temp, proc_cells+2, MPI_DOUBLE, 0, i_t, MPI_COMM_WORLD, mpistatus)
            call iter_temp(Temp, next_Temp, proc_cells, r)
            ! does not include padding:
            call MPI_Send(next_Temp, proc_cells, MPI_DOUBLE, 0, i_t, MPI_COMM_WORLD)
        end if
    end do

    call MPI_Finalize()

    if (rank == 0) then
        ! last save
        call save_step(OUTPUT, ncells, length, Temp, i_t*dt)
    end if
contains

    subroutine enforce_bounds(vec, n)
        real(c_double), parameter     :: lower_bound = 0, higher_bound = 100
        integer(c_int), intent(in)    :: n
        real(c_double), intent(inout) :: vec(0:n+1)

        vec(0) = lower_bound
        vec(n+1) = higher_bound
    end subroutine

    integer function get_interv_start(int_rank)
        integer(c_int), intent(in) :: int_rank
        ! ignores rank 0 and starts from rank 1. First index is 1
        get_interv_start = proc_cells*(int_rank-1)+1
    end function

    integer function get_intrv_stop(int_rank)
        integer(c_int), intent(in) :: int_rank
        get_intrv_stop = proc_cells*int_rank
    end function


    subroutine send_intervals()
        integer :: i_rank
        
        if (rank /= 0) return
        do i_rank=1, num_proc-1
            ! interval + padding
            call MPI_Send( &
                        Temp(get_interv_start(i_rank)-1:get_intrv_stop(i_rank)+1), &
                        proc_cells+2, MPI_DOUBLE, i_rank, i_t, &
                        MPI_COMM_WORLD)
        end do
    end subroutine

    subroutine recv_intervals()
        integer :: i_rank
        
        if (rank /= 0) return
        do i_rank=1, num_proc-1
            call MPI_Recv( &
                        next_Temp(get_interv_start(i_rank):get_intrv_stop(i_rank)), &
                        proc_cells, MPI_DOUBLE, i_rank, i_t, &
                        MPI_COMM_WORLD, mpistatus)
        end do
    end subroutine
end program