#!/bin/bash

# Empty the run directory - but first make sure it exists!
if [ -d "../run" ]; then
  cd ../run
  rm -rf *
else
  echo 'There is no run directory'
  exit 1
fi

# Link everything from the input directory
ln -s ../input/* . 

# Deep copy of the master namelist (so it doesn't get overwritten in input/)
rm -f data
cp -f ../input/data_shelfice data
cp -f ../input/data.exf_ERA5 data.exf

#echo 'Using default monthly diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_monthly data.diagnostics

echo 'Using shelfice package diagnostics.'
cp -f ../input/data.diagnostics_shelfice data.diagnostics

# Deep copy of any pickups (so they don't get overwritten in input/)
rm -f pickup*
cp -f ../input/restart_c68r/pickup* . 

# Link forcing files
ln -s /work/n02/n02/shared/baspog/ERA5/* .
../scripts/dummy_link.sh ERA5 1955 1978 1979 2002

pwd
# Link executables
ln -s ../build/mitgcmuv .
ln -s ../../../utilities/mit2nc/mit2nc .
