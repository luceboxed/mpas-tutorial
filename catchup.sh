#!/bin/bash
set -euo

cd
cd ~/mpas-workspace/mpas-tutorial
chmod +x ./preqs.sh
./preqs.sh
export NETCDF=/usr
export NETCDFF=/usr
export PNETCDF=/usr

cd ..
git clone https://github.com/MPAS-Dev/MPAS-Model
cd MPAS-Model
make -j6 gnu CORE=init_atmosphere AUTOCLEAN=true
make -j6 gnu CORE=atmosphere AUTOCLEAN=true

cd ..
wget -nv https://www2.mmm.ucar.edu/projects/mpas/mpas_static.tar.bz2 &
wget -nv https://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.40962.tar.gz &

ls -lh

mkdir -p ./model ./files/geog ./files/forcing ./files/mesh

tar -xjf mpas_static.tar.bz2 -C ./files/geog/ &
tar -xzf x1.40962.tar.gz -C ./files/mesh/ &

cd ./model

ln -s ~/mpas-workspace/MPAS-Model/init_atmosphere_model .
ln -s ~/mpas-workspace/MPAS-Model/atmosphere_model .
ln -s ~/mpas-workspace/MPAS-Model/src/core_atmosphere/physics/physics_wrf/files/* .

cp ~/mpas-workspace/MPAS-Model/namelist.init_atmosphere .
cp ~/mpas-workspace/MPAS-Model/namelist.atmosphere .
cp ~/mpas-workspace/MPAS-Model/streams.init_atmosphere .
cp ~/mpas-workspace/MPAS-Model/streams.atmosphere .
cp ~/mpas-workspace/MPAS-Model/stream_list.atmosphere.* .

cd ~/mpas-workspace/mpas-tutorial
chmod +x ./gfs_download.sh
./gfs_download.sh 4 &

cd ..
git clone https://github.com/wrf-model/WPS.git
cd WPS
./configure --nowrf --build-grib2-libs
./compile ungrib

wait

cp ~/mpas-workspace/files/mesh/x1.40962.grid.nc ~/mpas-workspace/model/
cp ~/mpas-workspace/files/mesh/x1.40962.graph.info.part.6 ~/mpas-workspace/model/
ln -s ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh ../files/forcing/GFS/*
