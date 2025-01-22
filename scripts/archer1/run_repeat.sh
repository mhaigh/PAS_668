#!/bin/bash --login
################################################################################
# Run the model for as long as we can, then prepare for a restart and submit the next job.
################################################################################
#PBS -l select=8
#PBS -q short
##PBS -l select=15
#PBS -l walltime=00:10:00
##PBS -l walltime=06:00:00
#PBS -e ../run
#PBS -o ../run
#PBS -j oe
#PBS -m n
#PBS -r n

# hardwire budget if you wish to over-ride default
#export HECACC=n02-bas
#export HECACC=n02-NEI025867
#export HECACC=n02-NER000107
#export HECACC=n02-NES011994

module load leave_time

cd $PBS_O_WORKDIR/../run

export TMPDIR=/work/n02/n02/`whoami`/SCRATCH
export OMP_NUM_THREADS=1

# start timer
timeqend="$(date +%s)"
elapsedqueue="$(expr $timeqend - $TIMEQSTART)"
timestart="$(date +%s)"
echo >> times
echo Queue-time seconds $elapsedqueue >> times
echo Run start `date` >> times

# Run the job but leave 1 minute at the end
leave_time 60 aprun -n 192 -N 24 ./mitgcmuv
#leave_time 60 aprun -n 360 -N 24 ./mitgcmuv
# Get the exit code
OUT=$?
echo 'job chain: leave_time activated, exit code' $OUT

# end timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Run end `date` >> times
echo Run-time seconds $elapsedtotal >> times

if ([ $OUT == 0 ] && [ $JOBCHUNK != 1 ]); then

  # Simulation completed and it was not chunk 1 of 2
 
  echo 'job chain: finished'

  # Move final stdout/stderr from the master node
  mv STDERR.0000 stderr_9999999999
  mv STDOUT.0000 stdout_9999999999

  # Transfer results back to BAS
  qsub -N PAS_${JOBNO}_rl \
     -A $HECACC \
     -V \
     -v JOBNO=$JOBNO \
     ../scripts/rsync_long.sh

elif [ $OUT == 124 ] || ([ $OUT == 0 ] && [ $JOBCHUNK == 1 ]); then

  # Simulation ran out of time or chunk 1 of 2 has completed
  # Prepare for a restart

  # Find the most recent pickup file
  unset -v PICKUP_FILE
  if ! ls pickup.*.data 1> /dev/null 2>&1 ; then
    echo 'job chain: fail, no pickup files'
    exit 1
  fi
  for file in pickup.*.data; do
    [[ $file -nt $PICKUP_FILE ]] && PICKUP_FILE=$file
  done
  # Extract the middle bit of this filename
  PICKUP=${PICKUP_FILE#pickup.}
  PICKUP=${PICKUP%.data}

  re='^[0-9]+$'
  if [[ $PICKUP =~ $re ]]; then

    echo 'job chain: pickup from permanent checkpoint'

    # Save the timestep, with any leading zeros removed
    NITER0=$(echo $PICKUP | sed 's/^0*//')
    # Make sure pickupSuff will be commented out in namelist
    PICKUP_LINE="# pickupSuff = 'ckptA'"

  elif [[ $PICKUP == ckptA || $PICKUP == ckptB ]]; then

    echo 'job chain: pickup from temporary checkpoint'

    # Read the timestep from the corresponding meta file
    PICKUP_META=pickup.$PICKUP.meta
    META_LINE=`sed -n '/timeStepNumber/p' $PICKUP_META`
    NITER0=$(echo $META_LINE | sed 's/[^0-9]*//g')
    # Make sure pickupSuff will be uncommented and correct
    PICKUP_LINE="\ pickupSuff = $PICKUP,"

  else

    echo 'job chain: fail, problem with pickup' $PICKUP
    exit 1

  fi

  # Edit the "data" namelist
  # Update the line which sets niter0 and is uncommented
  NITER0_LINE="\ niter0 = $NITER0,"
  sed -i "/^ niter0/c $NITER0_LINE" data
  # Update the line containing pickupSuff, whether or not it's commented
  # assumes there's only one!
  sed -i "/pickupSuff/c $PICKUP_LINE" data

  # If it is the end of the first chunk, edit stuff for second chunk
  if ([ $OUT == 0 ] && [ $JOBCHUNK == 1 ]); then

    echo 'first chunk complete, editing for second chunk'

    # Set new deltaT
    # find the commented chunkTwo line and extract its number
    TEXTLINE=`sed -n '/deltaT_chunkTwo/p' data`
    DELTAT_TWO=$(echo $TEXTLINE | sed -r 's/[^0-9.]*//g')
    # build the new active line and replace it in file
    TEXTLINE="\ deltaT = $DELTAT_TWO,"
    sed -i "/^ deltaT[ =]/c $TEXTLINE" data

    # Set niter0 to be consistent with new deltaT
    # find chunk 1 endTime divided by chunk 2 deltaT
    TEXTLINE=`sed -n '/^ endTime[ =]/p' data`
    ENDTIME_ONE=$(echo $TEXTLINE | sed -r 's/[^0-9.]*//g')
    NITER0_TWO=`python -c "print int($ENDTIME_ONE/$DELTAT_TWO)"`
    # build the new active line and replace it in file
    TEXTLINE="\ niter0 = $NITER0_TWO,"
    sed -i "/^ niter0/c $TEXTLINE" data

    # Set new endTime
    # find the commented chunkTwo line and extract its number
    TEXTLINE=`sed -n '/endTime_chunkTwo/p' data`
    ENDTIME_TWO=$(echo $TEXTLINE | sed -r 's/[^0-9.]*//g')
    # build the new active line and replace it in file
    TEXTLINE="\ endTime = $ENDTIME_TWO,"
    sed -i "/^ endTime/c $TEXTLINE" data

    # set pChkptFreq to what the user chose originally
    # (this was set to zero in chunk 1)
    TEXTLINE="\ pChkptFreq = $PCHKPTFREQ,"
    sed -i "/^ pChkptFreq/c $TEXTLINE" data

    # set the chunking flag to indicate we are no longer in the first chunk
    JOBCHUNK=0

  fi

  # Move stdout/stderr from the master node so they don't get overwritten
  NITER0FORMAT=`printf "%010i" $NITER0` 
  mv STDERR.0000 stderr_$NITER0FORMAT
  mv STDOUT.0000 stdout_$NITER0FORMAT

  # Submit next job
  TIMEQSTART="$(date +%s)"
  qsub -N PAS_$JOBNO \
       -A $HECACC \
       -v JOBCHUNK=$JOBCHUNK,JOBNO=$JOBNO,PCHKPTFREQ=$PCHKPTFREQ,TIMEQSTART=$TIMEQSTART \
       ../scripts/run_repeat.sh

else

  echo 'job chain: fail, simulation died, exit code' $OUT
  qsub -N PAS_${JOBNO}_rl \
     -A $HECACC \
     -V \
     -v JOBNO=$JOBNO \
     ../scripts/rsync_long.sh

fi

