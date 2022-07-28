# wrf-docker
A Dockerfile for the Weather Research and Forecasting (WRF) Model.

## Environment Variables
- `DIR`: path for WRF dependencies. Default to `/Build_WRF/LIBRARIES`.
- `WRF_DIR`: path for WRF. Default to `/Build_WRF/LIBRARIES/WRF-{version}`.

## Version
- MPICH: latest version in ubuntu:latest repo
- netcdf-4.1.3
- Jasper-1.900.1
- libpng-1.2.50
- zlib-1.2.7
- HDF5-1.8.22

## Usage

```
# assume you have data files in the current directory
docker run -ti -v $PWD:/root /bin/bash

# binary files in `/Build_WRF/LIBRARIES/WRF-{version}` and `/Build_WRF/LIBRARIES/WPS-{version}`
```
## TODO
- Add binary files directories to `$PATH`
- Optimize Dockerfile
- Publish to DockerHub

## Reference
- [Official tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php)
