#!/bin/bash
#SBATCH --time=0-1:0
#SBATCH --partition=amd-512
#SBATCH --cpus-per-task=128
#SBATCH --output=logs/%x/%j.out.log
#SBATCH --error=logs/%x/%j.err.log
#SBATCH --exclusive

# Script for NPAD cluster, npad.ufrn.br

srun pascalanalyzer ./wrapper_pascal.sh\
   --inst aut --idtm 5 --rpts 3\
   --cors 2,8,32,128\
   --ipts 500, 1000, 2000, 8000, 16000\
   --verb INFO -o navier_stokes_pascal0.json