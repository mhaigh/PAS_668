cd ../build
rm -rf *
$ROOTDIR/tools/genmake2 -ieee -mods=../code -of=../../../build_options/linux_amd64_scihub2 -mpi
make depend
make
