#!/bin/bash

# Empty the build directory - but first make sure it exists!
if [ -d "../build" ]; then
  cd ../build
  rm -rf *
else
  echo 'There is no build directory'
  exit 1
fi

# CODEDIR=../code

ROOTDIR=/work/n02/n02/michai1/mitgcm/MITgcm_c68r
CODEDIR=../code_68r

cd $CODEDIR
rm *.h *.F
cp exf2winds/* .

cd ../build
# Generate a Makefile
$ROOTDIR/tools/genmake2 -ieee -mpi -mods=$CODEDIR -of=$M_ROOT/build_options/linux_amd64_gfortran_archer2

echo $ROOTDIR

# Run the Makefile
make depend
make


