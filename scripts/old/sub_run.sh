#!/bin/bash

# set job id
JOBNO=666

# clean run directory and link all required files
./prep_run.sh


# submit the job
sbatch -J PAS_$JOBNO \
       -A $HECACC \
       run.sh

