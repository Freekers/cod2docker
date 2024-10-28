FROM ubuntu:noble

ARG cod2_version="1_0"
ARG libcod_url="https://github.com/voron00/libcod"
ARG libcod_commit=""
ARG libcod_mysql="0"
ARG libcod_sqlite="0"

# Set non-interactive mode to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# cod2 and libcod requirements
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        g++-multilib \
        libstdc++5:i386 \
        socat \
        git \
        ca-certificates \
    && if [ "$libcod_mysql" != "0" ]; then apt-get install -y libmysqlclient-dev:i386; fi \
    && if [ "$libcod_sqlite" != "0" ]; then apt-get install -y libsqlite3-dev:i386; fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy cod2 server file
COPY ./cod2_lnxded/${cod2_version} /cod2/cod2_lnxded

# Compile libcod
RUN git clone --depth 1 ${libcod_url} /cod2/libcod \
    && cd /cod2/libcod \
    && if [ -n "$libcod_commit" ]; then git checkout ${libcod_commit}; fi \
    && yes ${libcod_mysql} | ./doit.sh cod2_${cod2_version} \
    && cp /cod2/libcod/bin/libcod2_${cod2_version}.so /cod2/libcod.so \
    && rm -rf /cod2/libcod

# Set working directory
WORKDIR /cod2

# Healthcheck to verify server status
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD if [ -z "$(echo -e '\xff\xff\xff\xffgetinfo' | socat - udp:${CHECK_IP}:${CHECK_PORT})" ]; then exit 1; else exit 0; fi

# Preload libcod, unload it, and start the server
ENTRYPOINT ["/bin/sh", "-c", "echo '/cod2/libcod.so' > /etc/ld.so.preload && (sleep 15; echo '' > /etc/ld.so.preload) & /cod2/cod2_lnxded $PARAMS"]
