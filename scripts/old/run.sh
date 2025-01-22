#!/bin/bash
#SBATCH --time=0:10:0
#SBATCH --nodes=2
#SBATCH --tasks-per-node=96
#SBATCH --partition=standard
#SBATCH --cpus-per-task=1
# SBATCH --qos=standard
#SBATCH --qos=short
#SBATCH --reservation=shortqos
#SBATCH --chdir=../run

# Setup the job environment (this module needs to be loaded before any other modules)
# module load epcc-job-env

# Set the number of threads to 1
# export OMP_NUM_THREADS=1

# Set scratch directory
export TMPDIR=/work/n02/n02/`whoami`/SCRATCH

# run the job 
srun --distribution=block:block --hint=nomultithread ./mitgcmuv

