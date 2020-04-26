FROM ubuntu:bionic

ARG cod2_version="1_0"
ARG libcod_url="https://github.com/voron00/libcod"
ARG libcod_commit
ARG libcod_mysql="0"
ARG libcod_sqlite="0"

# cod2 and libcod requirements 
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
        g++-multilib \
        libstdc++5:i386 \
        netcat \
        git \
    && if [ "$libcod_mysql" != "0" ]; then apt-get install -y libmysqlclient-dev:i386; fi \
    && if [ "$libcod_sqlite" != "0" ]; then apt-get install -y libsqlite3-dev:i386; fi \
    && rm -rf /var/lib/apt/lists

# copy cod2 server file
COPY ./cod2_lnxded/${cod2_version} /cod2/cod2_lnxded

# compile libcod
RUN cd /cod2 \
    && git clone ${libcod_url} \
    && cd libcod \
    && if [ -z "$libcod_commit" ]; then git checkout ${libcod_commit}; fi \
    && yes ${libcod_mysql} | ./doit.sh cod2_${cod2_version} \
    && cp /cod2/libcod/bin/libcod2_${cod2_version}.so /cod2/libcod.so \
    && rm -rf /cod2/libcod

# base dir
WORKDIR /cod2

# check server info every 30 seconds
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD if [ -z "$(echo -e '\xff\xff\xff\xffgetinfo' | nc -w 1 -u ${CHECK_IP} ${CHECK_PORT})" ]; then exit 1; else exit 0; fi

# preload libcod
# plan to unload it
# start the server
ENTRYPOINT echo "/cod2/libcod.so" > /etc/ld.so.preload; \
    (sleep 15; echo "" > /etc/ld.so.preload) & \
    /cod2/cod2_lnxded "$PARAMS"
