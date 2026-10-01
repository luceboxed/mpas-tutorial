#!/bin/bash
set -eu

echo 'modeling club tutorial catchup script'
echo 'gathering preqs (step 1b)'
echo '---------------------------------------'

cd
cd ~/mpas-workspace/mpas-tutorial
chmod +x ./preqs.sh
./preqs.sh
export NETCDF=/usr
export NETCDFF=/usr
export PNETCDF=/usr

echo '---------------------------------------'
echo 'downloading and compiling MPAS (step 2a)'
echo '---------------------------------------'

cd ..
git clone https://github.com/MPAS-Dev/MPAS-Model
cd MPAS-Model
make -j6 gnu CORE=init_atmosphere AUTOCLEAN=true
make -j6 gnu CORE=atmosphere AUTOCLEAN=true

echo '---------------------------------------'
echo 'gathering and staging geography dataset/meshes, setting up directories, and copying files (steps 2b-2d)'
echo '---------------------------------------'

cd ..
wget -nv https://www2.mmm.ucar.edu/projects/mpas/mpas_static.tar.bz2 &
wget -nv https://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.40962.tar.gz &

ls -lh

mkdir -p ./model ./files/geog ./files/forcing ./files/mesh

cd ./model

ln -s ~/mpas-workspace/MPAS-Model/init_atmosphere_model .
ln -s ~/mpas-workspace/MPAS-Model/atmosphere_model .
ln -s ~/mpas-workspace/MPAS-Model/src/core_atmosphere/physics/physics_wrf/files/* .

cp ~/mpas-workspace/MPAS-Model/namelist.init_atmosphere .
cp ~/mpas-workspace/MPAS-Model/namelist.atmosphere .
cp ~/mpas-workspace/MPAS-Model/streams.init_atmosphere .
cp ~/mpas-workspace/MPAS-Model/streams.atmosphere .
cp ~/mpas-workspace/MPAS-Model/stream_list.atmosphere.* .

echo '---------------------------------------'
echo 'downloading GFS data (step 3a)'
echo 'NOTE: PLEASE KEEP TRACK OF THE DATE IT SAYS!'
echo '---------------------------------------'

cd ~/mpas-workspace/mpas-tutorial
chmod +x ./gfs_download.sh
./gfs_download.sh 4 &

echo '---------------------------------------'
echo 'downloading and compiling ungrib (step 3b'
echo '---------------------------------------'

cd ..
git clone https://github.com/wrf-model/WPS.git
cd WPS
echo 'Choose OPTION 1 unless you know what you are doing below:'
./configure --nowrf --build-grib2-libs
./compile ungrib
ln -s ungrib/Variable_Tables/Vtable.GFS Vtable


echo '---------------------------------------'
echo 'awaiting the finishing of downloads, may hang here for a minute! that is OK!'
echo '---------------------------------------'

wait

echo '---------------------------------------'
echo 'uncompressing and moving meshes and forcing data... it again may hang here for a minute! that is OK!'
echo '---------------------------------------'
tar -xvjf ~/mpas-workspace/mpas_static.tar.bz2 -C ~/mpas-workspace/files/geog/ &
tar -xvzf ~/mpas-workspace/x1.40962.tar.gz -C ~/mpas-workspace/files/mesh/ &
wait
cp ~/mpas-workspace/files/mesh/x1.40962.grid.nc ~/mpas-workspace/model/
cp ~/mpas-workspace/files/mesh/x1.40962.graph.info.part.6 ~/mpas-workspace/model/
cd ~/mpas-workspace/WPS/
~/mpas-workspace/WPS/link_grib.csh ~/mpas-workspace/files/forcing/GFS/*
