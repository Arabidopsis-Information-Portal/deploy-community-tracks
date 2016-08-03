######################################################
#
# Araport - Deploy community JBrowse tracks Image
# Tag: araport/deploy-community-tracks
#
# This container makes genomic data format files (GFF, BED, & VCF) available as community
# JBrowse tracks on Araport.
#
# docker run -it -v $HOME/.agave:/root/.agave -v ${PWD}:/data araport/deploy-community-tracks [GDF-file]
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
    && apt-get update && apt-get install -y $buildDeps bzip2 genometools vcftools perl-base --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget "$HTSLIB_DOWNLOAD_URL" \
    && mkdir -p /usr/src/htslib \
    && tar -jxf htslib-1.3.1.tar.bz2 -C /usr/src/htslib --strip-components=1 \
    && rm htslib-1.3.1.tar.bz2 \
    && make -C /usr/src/htslib \
    && make -C /usr/src/htslib install \
    && rm -r /usr/src/htslib \
    && apt-get purge -y --auto-remove $buildDeps

ADD agave-cli.tgz /usr/local

RUN /usr/local/agave-cli/bin/tenants-init -b -t iplantc.org

COPY src/process_genomic_data_format_files.sh /usr/local/bin
COPY src/normalize_athaliana_chrom_ids.pl /usr/local/bin
RUN chmod a+x /usr/local/bin/*

RUN mkdir /data

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/process_genomic_data_format_files.sh"]
