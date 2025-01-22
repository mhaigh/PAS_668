#!/bin/bash --login
################################################################################
# Run the model for as long as we can, then prepare for a restart and submit the next job.
################################################################################

#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --nodes=2
#SBATCH --tasks-per-node=120
#SBATCH --time=08:00:00
#SBATCH --no-requeue
#SBATCH --export=none
#SBATCH --chdir=../run

# following can be uncommented in place of some of the above
# for short test runs.

# SBATCH --time=00:20:00
# SBATCH --qos=short
# SBATCH --reservation=shortqos

#===============================================================================

# function to return numbwer of seconds left in this job
# the squeue command returns either hh:mm:ss or mm:ss
# so handle both cases.
# We should add in 1-00:00:00 for a day

function hmsleft()
{
	local lhms
	lhms=$(squeue  -j $SLURM_JOB_ID -O TimeLeft | tail -1)
	echo $lhms
}
function secsleft() {
    if [[ ${#hms} < 6 ]]
    then
        echo secs=$(echo $hms|awk -F: '{print ($1 * 60) + $2 }')
    else
        echo secs=$(echo $hms|awk -F: '{print ($1 * 3600) + ($2 * 60) + $3 }')
    fi
}


echo "received from SLURM", JOBNO=$JOBNO, PCHKPTFREQ=$PCHKPTFREQ, TIMEQSTART=$TIMEQSTART

# run this in run directory? cd $PBS_O_WORKDIR/../run
export TMPDIR=/work/n02/n02/`whoami`/SCRATCH
export OMP_NUM_THREADS=1

# start timer
timeqend="$(date +%s)"
elapsedqueue="$(expr $timeqend - $TIMEQSTART)"
timestart="$(date +%s)"
echo >> times
echo Queue-time seconds $elapsedqueue >> times
echo Run start `date` >> times
hms=$(hmsleft)
echo Walltime left is $hms>>walltime
rem_secs=$(secsleft)  # function above
echo Walltime left in seconds is $rem_secs >> walltime
# Subtract 3 minutes
RUNTIME="$(($rem_secs-180))"
echo Will run for $RUNTIME sec >> walltime

# Run the job but leave 3 minutes at the end
timeout $RUNTIME  srun --distribution=block:block --hint=nomultithread mitgcmuv

# Get the exit code
OUT=$?
echo 'job chain: leave_time activated, exit code' $OUT

# End timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Run end `date` >> times
echo Run-time seconds $elapsedtotal >> times


if [ $OUT == 0 ]; then

  # Simulation completed
 
  echo 'job chain: finished'

  # Move final stdout/stderr from the master node
  mv STDERR.0000 stderr_9999999999
  mv STDOUT.0000 stdout_9999999999


elif [ $OUT == 124 ]; then

  # Simulation ran out of time
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
    PICKUP_LINE="\ pickupSuff = '$PICKUP',"

  else

    echo 'job chain: fail, problem with pickup' $PICKUP
    exit 1

  fi
  echo 'PICKUP_LINE: ' $PICKUP_LINE
  echo 'NITER0: ' $NITER0

  # Edit the "data" namelist
  # Update the line which sets niter0 and is uncommented
  NITER0_LINE="\ niter0 = $NITER0,"
  sed -i "/^ niter0/c $NITER0_LINE" data
  # Update the line containing pickupSuff, whether or not it's commented
  # assumes there's only one!
  sed -i "/pickupSuff/c $PICKUP_LINE" data

  # Move stdout/stderr from the master node so they don't get overwritten
  NITER0FORMAT=`printf "%010i" $NITER0` 
  mv STDERR.0000 stderr_$NITER0FORMAT
  mv STDOUT.0000 stdout_$NITER0FORMAT

  # Resubmit the job (may cause error if $HECACC empty)
  sbatch -J PAS_$JOBNO  \
     -A $HECACC \
     --export HECACC=$HECACC,JOBNO=$JOBNO,PCHKPTFREQ=$PCHKPTFREQ,TIMEQSTART=$TIMEQSTART \
     ../scripts/run_repeat.sh

else

  echo 'job chain: fail, simulation died, exit code' $OUT

fi

