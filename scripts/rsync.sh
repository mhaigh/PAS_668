#!/bin/bash

JOBNO=666

# move to run directory
cd ../run

# make target directory
HOMEDIR=$HOMEROOT/PAS_${JOBNO}/run
ssh $HOMEHOST "mkdir -p $HOMEDIR"

# rsync peripheral files
rsync -avzL hFac* $HOMEHOST:$HOMEDIR
rsync -avzL Depth* $HOMEHOST:$HOMEDIR
rsync -avzL DRF* $HOMEHOST:$HOMEDIR
rsync -avzL DRC* $HOMEHOST:$HOMEDIR
rsync -avzL DXG* $HOMEHOST:$HOMEDIR
rsync -avzL DYG* $HOMEHOST:$HOMEDIR
rsync -avzL RAC* $HOMEHOST:$HOMEDIR
rsync -avzL RC* $HOMEHOST:$HOMEDIR
rsync -avzL RF* $HOMEHOST:$HOMEDIR
rsync -avzL XC* $HOMEHOST:$HOMEDIR
rsync -avzL YC* $HOMEHOST:$HOMEDIR
rsync -avzL XG* $HOMEHOST:$HOMEDIR
rsync -avzL YG* $HOMEHOST:$HOMEDIR
rsync -avzL stdout_* $HOMEHOST:$HOMEDIR

#rsync -avzL stateUvel.*.data $HOMEHOST:$HOMEDIR

# for each diagnostic file, make netcdf and rsync
VARS="
      state2D
     "
#      stateTheta
#      stateSalt
#      stateRho
#      stateExf
#      stateUvel
#      stateVvel
#      stateWvel
#      stateUdpdx
#      stateVdpdy
#      "

for VAR in $VARS
do
  rm -rf $VAR.nc
  echo 'seconds since 1979-01-01 00:00:00' > file_list
  ls $VAR.*.data >> file_list
  ./mit2nc
  rsync -avzL $VAR.nc $HOMEHOST:$HOMEDIR
  rm -rf $VAR.nc
done

