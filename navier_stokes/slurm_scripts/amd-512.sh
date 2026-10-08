#!/bin/bash
#SBATCH --time=0-12:0
#SBATCH --partition=amd-512
#SBATCH --output=/dev/null
#SBATCH --error=/dev/null
#SBATCH --cpus-per-task=128

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Script for NPAD cluster, npad.ufrn.br
LOG_PATH="logs/$SLURM_JOB_NAME/$SLURM_JOB_ID"
mkdir -p "$LOG_PATH"
# log files for this script
exec > "$LOG_PATH/master.log.out"
exec 2> "$LOG_PATH/master.log.err"

module load softwares/pascalsuite/2025-07-08

echo "Running at $SLURM_JOB_NODELIST."

srun --output="$LOG_PATH/log.out" --error="$LOG_PATH/log.err"\
   pascalanalyzer ./wrapper_pascal.sh\
   --inst aut --idtm 5 --rpts 3\
   --cors 1,4,16,64\
   --ipts 10,40,160,640\
   --verb INFO -o results/navier_stokes_pascal0.json