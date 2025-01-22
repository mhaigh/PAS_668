#!/bin/bash
#

# script for submitting mpi job to scihub 
./clean.sh

sbatch -J TEST_004 ./run_scihub2.sh
