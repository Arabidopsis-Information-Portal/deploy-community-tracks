FROM ubuntu:16.04
MAINTAINER Erik Ferlanti <eferlanti@tacc.utexas.edu>

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

ENV HTSLIB_DOWNLOAD_URL https://github.com/samtools/htslib/releases/download/1.3.1/htslib-1.3.1.tar.bz2

RUN buildDeps='gcc libc6-dev make zlib1g-dev' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps bzip2 genometools --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget "$HTSLIB_DOWNLOAD_URL" \
    && mkdir -p /usr/src/htslib \
    && tar -jxf htslib-1.3.1.tar.bz2 -C /usr/src/htslib --strip-components=1 \
    && rm htslib-1.3.1.tar.bz2 \
    && make -C /usr/src/htslib \
    && make -C /usr/src/htslib install \
    && rm -r /usr/src/htslib \
    && apt-get purge -y --auto-remove $buildDeps

ENV ICOMMANDS_DOWNLOAD_URL https://pods.iplantcollaborative.org/wiki/download/attachments/6720192/icommands-3.3.1-linux-autobuf.tgz

RUN mkdir /usr/local/icommands \
    && wget "$ICOMMANDS_DOWNLOAD_URL" \
    && tar -zxf icommands-3.3.1-linux-autobuf.tgz -C /usr/local/icommands --strip-components=1 \
    && rm icommands-3.3.1-linux-autobuf.tgz

ENV PATH "$PATH:/usr/local/icommands/bin"

COPY src/process_gff.sh /usr/local/bin

RUN mkdir /data

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/process_gff.sh"]
