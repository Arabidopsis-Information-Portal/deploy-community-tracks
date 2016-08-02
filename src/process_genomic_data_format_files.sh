#!/bin/bash

set -euo pipefail
#set -x

SYSTEM_ID="{{SYSTEM_ID}}"
SHARED_DIR="{{SHARED_DIR}}"
TRACK_URL_BASE="{{TRACK_URL_BASE}}"
ANONYMOUS_USER="{{ANONYMOUS_USER}}"
ARAPORT_USER="{{ARAPORT_USER}}"

# set some defaults
BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JB_STORE_CLASS="JBrowse/Store/SeqFeature/"
EXEC_NORMALIZE_CHROM_ID="${BINDIR}/normalize_athaliana_chrom_ids.pl"

# read positional params
FULL_GDF=$1
DESCRIPTION=$2

# determine type and generate filenames
BASE_GDF=$(basename "$FULL_GDF")
EXT_GDF=${BASE_GDF##*.}
#FILE_TYPE=${EXT_GDF,,} # bash 4.x only!
FILE_TYPE=$(echo "$EXT_GDF" | tr '[:upper:]' '[:lower:]')
NAME_GDF=${BASE_GDF%.*}
SORTED_GDF=$NAME_GDF.sorted.$EXT_GDF
GZIP_GDF=$SORTED_GDF.gz
TABIX_GDF=$GZIP_GDF.tbi
JBROWSE_CONF=$NAME_GDF.conf

if [[ $FILE_TYPE = "gff" ]]; then
    # validate the GFF file (using genometools)
    gt gff3validator -typecheck so "$FULL_GDF"

    # sort the GFF (using genometools)
    #gt gff3 -sortlines yes -tidy yes -retainids yes -addids no -checkids yes $FULL_GFF >$SORTED_GFF

    # sort the GFF (using sort)
    (grep ^"#" "$FULL_GDF"; grep -v ^"#" "$FULL_GDF" | ${EXEC_NORMALIZE_CHROM_ID} | sort -k1,1 -k4,4n) >"$SORTED_GDF"
    JB_STORE_CLASS+="GFF3Tabix"
elif [[ $FILE_TYPE = "bed" ]]; then
    # sort the BED (using sort)
    ${EXEC_NORMALIZE_CHROM_ID} "$FULL_GDF" | sort -k1,1 -k2,2n >"$SORTED_GDF"
    JB_STORE_CLASS+="BEDTabix"
elif [[ $FILE_TYPE = "vcf" ]]; then
    # sort the VCF (using vcftools)
    ${EXEC_NORMALIZE_CHROM_ID} "$FULL_GDF" | vcf-sort >"$SORTED_GDF"
    JB_STORE_CLASS+="VCFTabix"
else
    echo "File type not recognized (supports gff, bed, or vcf)."
    exit 1
fi

# compress and index
bgzip "$SORTED_GDF"
tabix -p "$FILE_TYPE" "$GZIP_GDF"

# upload the files to iplant
/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEM_ID" -F "$GZIP_GDF" "$SHARED_DIR"
/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEM_ID" -F "$TABIX_GDF" "$SHARED_DIR"

# construct (and upload) a JBrowse config file referencing the GFF3 file
cat <<EOT >> "$JBROWSE_CONF"
[tracks.$NAME_GDF]
storeClass  = $JB_STORE_CLASS
type        = JBrowse/View/Track/CanvasFeatures
category    = Community Data Tracks
key         = $DESCRIPTION
urlTemplate = $TRACK_URL_BASE/$SHARED_DIR/${SORTED_GDF}.gz
EOT

/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEM_ID" -F "$JBROWSE_CONF" "$SHARED_DIR"

# make share directory readable by anonymous
/usr/local/cyverse-cli/bin/files-pems-update -f -R -S "$SYSTEM_ID" -U "$ANONYMOUS_USER" -P READ "$SHARED_DIR"
# make share directory readable and writable by araport
/usr/local/cyverse-cli/bin/files-pems-update -f -R -S "$SYSTEM_ID" -U "$ARAPORT_USER" -P READ_WRITE "$SHARED_DIR"
