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

# rsync peripheral files
rsync -avzL hFac* $HOMEHOST:$HOMEDIR
rsync -avzL Depth* $HOMEHOST:$HOMEDIR
rsync -avzL DRF* $HOMEHOST:$HOMEDIR
rsync -avzL DXG* $HOMEHOST:$HOMEDIR
rsync -avzL DYG* $HOMEHOST:$HOMEDIR
rsync -avzL RAC* $HOMEHOST:$HOMEDIR
rsync -avzL RC* $HOMEHOST:$HOMEDIR
rsync -avzL XC* $HOMEHOST:$HOMEDIR
rsync -avzL YC* $HOMEHOST:$HOMEDIR
rsync -avzL stdout_* $HOMEHOST:$HOMEDIR

# pad meta files for crash files so that mit2nc works
# (copy -noclobber to ensure only done once)
for file in *crash*.meta; do
  cp -n $file ${file}_original  
  cat ${file}_original ../scripts/crashmeta.txt > $file
done

# for each diagnostic file, make netcdf and rsync
VARS="
      stateEtacrash
      stateThetacrash
      stateSaltcrash
      stateUvelcrash
      stateVvelcrash
      stateWvelcrash
      state2D
      stateTheta
      stateSalt
      stateRho
      stateExf
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
  rsync -avzL $VAR.nc $HOMEHOST:$HOMEDIR
  rm -rf $VAR.nc
done

# end timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Sync end `date` >> times
echo Sync-time seconds: $elapsedtotal >> times


