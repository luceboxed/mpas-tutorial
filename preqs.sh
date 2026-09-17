# Intended for building of MPAS-A on WSL running Ubuntu.

sudo apt update && sudo apt install -y \
  build-essential gfortran gcc g++ make \
  openmpi-bin libopenmpi-dev \
  libnetcdf-dev libnetcdff-dev libpnetcdf-dev \
  libpng-dev zlib1g-dev libjasper-dev \
  bzip2 csh tcsh git m4

sudo ln -sf /usr/lib/x86_64-linux-gnu/libnetcdf* /usr/lib/
sudo ln -sf /usr/lib/x86_64-linux-gnu/libpnetcdf* /usr/lib/

echo "export NETCDF=/usr" >> ~/.bashrc
echo "export NETCDFF=/usr" >> ~/.bashrc
echo "export PNETCDF=/usr" >> ~/.bashrc
source ~/.bashrc
