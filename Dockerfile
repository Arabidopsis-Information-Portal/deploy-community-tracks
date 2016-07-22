######################################################
#
# Araport - Deploy community JBrowse tracks Image
# Tag: araport/deploy-community-tracks
#
# This container makes GFF3 files available as community
# JBrowse tracks on Araport.
#
# docker run -it -v $HOME/.agave:/root/.agave -v ${PWD}:/data araport/deploy-community-tracks [GFF-file]
#
######################################################
FROM ubuntu:16.04
MAINTAINER Erik Ferlanti <eferlanti@tacc.utexas.edu>

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    curl \
    vim.tiny \
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

ADD cyverse-cli.tgz /usr/local

RUN /usr/local/cyverse-cli/bin/tenants-init -b -t iplantc.org

COPY src/process_gff.sh /usr/local/bin

RUN mkdir /data

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/process_gff.sh"]
