#!/bin/bash --login
#
#PBS -e ../run
#PBS -j oe
#PBS -m n
#PBS -o ../run
#PBS -l select=serial=true:ncpus=1
#PBS -r n
#PBS -l walltime=24:00:00 

# prepare stuff
cd $PBS_O_WORKDIR/../run

# start timer
timestart="$(date +%s)"
echo >> times
echo Sync start `date` >> times

# make target directory
HOMEDIR=$HOMEROOT/PAS_${JOBNO}/run
ssh -t $HOMEHOST "mkdir -p $HOMEDIR"

# scp peripheral files
scp hFac* $HOMEHOST:$HOMEDIR
scp Depth* $HOMEHOST:$HOMEDIR
scp DRF* $HOMEHOST:$HOMEDIR
scp DXG* $HOMEHOST:$HOMEDIR
scp DYG* $HOMEHOST:$HOMEDIR
scp RAC* $HOMEHOST:$HOMEDIR
scp RC* $HOMEHOST:$HOMEDIR
scp XC* $HOMEHOST:$HOMEDIR
scp YC* $HOMEHOST:$HOMEDIR
scp stdout_* $HOMEHOST:$HOMEDIR

# pad meta files for crash files so that mit2nc works
# (copy -noclobber to ensure only done once)
for file in *crash*.meta; do
  cp -n $file ${file}_original  
  cat ${file}_original ../scripts/crashmeta.txt > $file
done

# for each diagnostic file, make netcdf and scp
VARS="
      stateEtacrash
      stateThetacrash
      stateSaltcrash
      stateUvelcrash
      stateVvelcrash
      stateWvelcrash
      state2D
      stateExf
      stateTheta
      stateSalt
      stateRho
      stateUvel
      stateVvel
      stateWvel
      stateAdvxT
      stateAdvyT
      stateUdpdx
      stateVdpdy
      stateKPP
     "

for VAR in $VARS
do
  rm -rf $VAR.nc
#  echo 'seconds since 1920-01-01 00:00:00' > file_list
  echo 'seconds since 1955-01-01 00:00:00' > file_list
  ls $VAR.*.data >> file_list
  ./mit2nc
  scp $VAR.nc $HOMEHOST:$HOMEDIR
  rm -rf $VAR.nc
done

# end timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Sync end `date` >> times
echo Sync-time seconds: $elapsedtotal >> times


