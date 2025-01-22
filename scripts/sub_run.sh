#!/bin/bash
################################################
# Start a self-resubmitting simulation.
################################################

# ID number for run
JOBNO=666

# record start times
TIMEQSTART="$(date +%s)"
echo Start-time `date` >> ../run/times

echo $HECACC
# submit the job chain
sbatch -J PAS_$JOBNO  \
     -A $HECACC \
     --export HECACC=$HECACC,JOBNO=$JOBNO,PCHKPTFREQ=$PCHKPTFREQ,TIMEQSTART=$TIMEQSTART \
     ../scripts/run_repeat.sh

