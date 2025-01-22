#!/bin/bash
################################################
# Start a self-resubmitting simulation.
################################################

# ID number for run
JOBNO=666

# clean run directory and link all required files
./prep_run.sh

# record start times
TIMEQSTART="$(date +%s)"
echo Start-time `date` >> ../run/times

# initialise a variable indicating chunking status
# 1: we are running chunk 1 of 2
# else: any other situation
JOBCHUNK=0

# if we are doing chunking, we can't have permanent checkpoints in the first chunk
# but we need to save the value of pChkptFreq for the second chunk
if [ $JOBCHUNK == 1 ]; then

  # find uncommented pChkptFreq line and extract its number
  TEXTLINE=`sed -n '/^ pChkptFreq[ =]/p' ../run/data`
  PCHKPTFREQ=$(echo $TEXTLINE | sed -r 's/[^0-9.]*//g')

  # set pChkptFreq to zero
  TEXTLINE="\ pChkptFreq = 0.0,"
  sed -i "/^ pChkptFreq/c $TEXTLINE" ../run/data

fi

# submit the job chain
qsub -N PAS_$JOBNO \
     -A $HECACC \
     -v JOBCHUNK=$JOBCHUNK,JOBNO=$JOBNO,PCHKPTFREQ=$PCHKPTFREQ,TIMEQSTART=$TIMEQSTART \
     run_repeat.sh

