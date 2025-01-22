#!/bin/bash

# set job id
JOBNO=666

echo $HECACC

# submit the job
sbatch -J PAS_$JOBNO \
       --account $HECACC \
       --export=ALL \
       rsync_a2.sh

