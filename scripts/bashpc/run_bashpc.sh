#!/bin/bash
#
#SBATCH --chdir=/data/hpcdata/users/davbet33/mitgcm/cases/Iceberg_013/run/
#SBATCH --output=job.out
##SBATCH --mail-type=begin,end,fail,requeue    ## When to email you
##SBATCH --mail-user=davbet33@bas.ac.uk        ## Your email address
#SBATCH --time=00:20:00                       ## Maximum CPU time
#SBATCH --nodes=1                             ## Run on 1 node
#SBATCH --ntasks-per-node=1                  ## Run 44 tasks per node
#SBATCH --ntasks-per-socket=1                ## Run 44 tasks per node
#SBATCH --ntasks-per-core=1
#SBATCH --partition=short                    ## Which Partition/Queue to use
#SBATCH --account=short                      ## must match partition

#echo commands to stdout
set -x

source /etc/profile.d/modules.sh
module purge 
module load hpc/hdf5/gcc/1.10.4
module load hpc/mvapich2/gcc/2.2
module load hpc/netcdf/gcc/4.4.1.1
module load hpc/gcc/7.2.0
module load hpc/openmpi/gcc

#run mpi program
mpirun -np $SLURM_NTASKS mitgcmuv
