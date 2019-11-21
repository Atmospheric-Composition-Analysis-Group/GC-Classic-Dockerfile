FROM liambindle/penelope:0.1.0-ubuntu16.04-gcc7-netcdf4.5.0-netcdff4.4.4

# Make bash the default shell
SHELL ["/bin/bash", "-c"]

# Make a directory to install GEOS-Chem to
RUN mkdir /opt/geos-chem && mkdir /opt/geos-chem/bin

# Clone GEOS-Chem and checkout the appropriate version
RUN git clone https://github.com/geoschem/geos-chem.git /gc-src \
&&  cd /gc-src \
&&  git checkout dev/12.7.0 \
&&  mkdir build

# Commands to properly set up the environment inside the container
RUN echo "module load gcc/7" >> /init.rc \
&&  echo "spack load hdf5" >> /init.rc \
&&  echo "spack load netcdf" >> /init.rc \
&&  echo "spack load netcdf-fortran" >> /init.rc \
&&  echo "export PATH=$PATH:/opt/geos-chem/bin" >> /init.rc

# Build Standard and copy the executable to /opt/geos-chem/bin
RUN source /init.rc \
&&  cd /gc-src/build \
&&  cmake -DRUNDIR=IGNORE -DRUNDIR_SIM=standard -DCMAKE_COLOR_MAKEFILE=OFF .. \
&&  make -j install \
&&  cp geos /opt/geos-chem/bin/geos-chem-standard

RUN rm -rf /gc-src

RUN echo "#!/usr/bin/env bash" > /usr/bin/start-container.sh \
&&  echo ". /init.rc" >> /usr/bin/start-container.sh \
&&  echo 'if [ $# -gt 0 ]; then exec "$@"; else /bin/bash ; fi' >> /usr/bin/start-container.sh \
&&  chmod +x /usr/bin/start-container.sh
ENTRYPOINT ["start-container.sh"]