FROM ubuntu:20.04
MAINTAINER Cheng Zhen <hi@wogong.net>

# Set up base OS environment
RUN apt update -y
RUN apt install -y gcc g++ gfortran m4 make wget vim-tiny csh git
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt -y install mpich

# Set ENV
RUN mkdir -p /Build_WRF/LIBRARIES
ENV DIR /Build_WRF/LIBRARIES
ENV WRF_DIR /Build_WRF/LIBRARIES/WRFV4.4
ENV CC gcc
ENV CXX g++
ENV FC gfortran
ENV FCFLAGS -m64
ENV F77 gfortran
ENV FFLAGS -m64
ENV JASPERLIB $DIR/grib2/lib
ENV JASPERINC $DIR/grib2/include
ENV LDFLAGS -L$DIR/grib2/lib
ENV CPPFLAGS -I$DIR/grib2/include
ENV J 16

# Build zlib
RUN cd $DIR \
 && wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz \
 && tar xzvf zlib-1.2.7.tar.gz \
 && cd zlib-1.2.7 \
 && ./configure --prefix=$DIR/grib2 \
 && make -j $J \
 && make install

# Build HDF5
RUN cd $DIR \
 && wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.22/src/hdf5-1.8.22.tar.gz \
 && tar xvf hdf5-1.8.22.tar.gz \
 && cd hdf5-1.8.22 \
 && ./configure --prefix=$DIR/hdf5 --enable-fortran --enable-fortran2003 --enable-cxx \
 && make -j $J\
 && make install

# Build NetCDF
RUN cd $DIR \
 && wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz \
 && tar xzvf netcdf-4.1.3.tar.gz \
 && cd netcdf-4.1.3 \
 && ./configure --prefix=$DIR/netcdf CPPFLAGS="-I$DIR/hdf5/include -I/$DIR/grib2/include" LDFLAGS="-L$DIR/hdf5/lib -L$DIR/grib2/lib" \
 && make -j $J \
 && make install
ENV PATH $DIR/netcdf/bin:$PATH
ENV NETCDF $DIR/netcdf
ENV LD_LIBRARY_PATH $DIR/netcdf/lib:$LD_LIBRARY_PATH

# Build MPICH, so slow that we use the pre built binary in official repo
#RUN apt install -y python3
#RUN cd $DIR \
# && wget https://www.mpich.org/static/downloads/4.0.2/mpich-4.0.2.tar.gz \
# && tar xzvf mpich-4.0.2.tar.gz \
# && cd mpich-4.0.2 \
# && ./configure --prefix=$DIR/mpich FFLAGS=-fallow-argument-mismatch FCFLAGS=-fallow-argument-mismatch \
# && make -j $J \
# && make install
#ENV PATH $DIR/mpich/bin:$PATH

# Build libpng
RUN cd $DIR \
 && wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz \
 && tar xzvf libpng-1.2.50.tar.gz \
 && cd libpng-1.2.50 \
 && ./configure --prefix=$DIR/grib2 \
 && make -j $J \
 && make install

# Build jasper
RUN cd $DIR \
 && wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz \
 && tar xzvf jasper-1.900.1.tar.gz \
 && cd jasper-1.900.1 \
 && ./configure --prefix=$DIR/grib2 \
 && make -j $J\
 && make install
ENV LD_LIBRARY_PATH $DIR/grib2/lib:$LD_LIBRARY_PATH

# Download WRF and WPS
RUN cd $DIR \
 && wget -O wrf.tar.gz https://github.com/wrf-model/WRF/releases/download/v4.4/v4.4.tar.gz \
 && wget -O wps.tar.gz https://github.com/wrf-model/WPS/archive/refs/tags/v4.4.tar.gz \
 && tar xzvf wrf.tar.gz \
 && tar xzvf wps.tar.gz

# Build WRF
RUN cd $DIR/WRFV4.4 \
 &&  (printf "34\n1\n" && cat) | ./configure

RUN cd $DIR/WRFV4.4 \
 && ./compile em_real

# Build WPS
RUN cd $DIR/WPS-4.4 \
 &&  (printf "1\n" && cat) | ./configure

RUN cd $DIR/WPS-4.4 \
 && sed -i "s/CONFIGURE_COMPAT_FLAGS//" configure.wps \
 && ./compile
