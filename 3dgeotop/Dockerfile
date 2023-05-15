FROM ghcr.io/osgeo/gdal:ubuntu-small-latest

RUN apt-get update && apt-get install -y liblaszip8 \
                                         python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

# next line equivalent to: pip install pygments prompt-toolkit setproctitle xonsh
RUN pip3 install 'xonsh[full]'
RUN pip3 install laspy[laszip]
RUN pip3 install py3dtiles
RUN pip3 install xontrib-argcomplete

# allow numba to do its thing even with unprivileged user
ENV NUMBA_CACHE_DIR=/tmp

COPY interactive.xsh /etc/xonshrc
COPY interactive.xsh /root/.xonshrc

COPY gt2pc.xsh /usr/bin/gt2pc
COPY lut.csv /home/lut.csv

RUN mkdir /.local /.cache /.config
RUN chmod -R 777 /.local /.cache /.config /tmp

CMD ["/usr/bin/gt2pc.xsh"]
