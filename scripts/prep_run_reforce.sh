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
rm -f data.exf
rm -f data.diagnostics
rm -f data.pkg
cp -f ../input/data_reforce data
cp -f ../input/data.exf_reforce data.exf
cp -f ../input/data.diagnostics_reforce data.diagnostics
cp -f ../input/data.pkg_reforce data.pkg

# Deep copy of any pickups (so they don't get overwritten in input/)
rm -f pickup*
cp -f ../input/restart_c68r/pickup* . 

# Link forcing files
ln -s /work/n02/n02/shared/baspog/ERA5/ERA5_apressure* .
ln -s /work/n02/n02/shared/baspog/reforce_michai/* .

pwd
# Link executables
ln -s ../build/mitgcmuv .
ln -s ../../../utilities/mit2nc/mit2nc .
