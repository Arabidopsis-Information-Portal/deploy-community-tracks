#!/bin/bash

set -euo pipefail
set -x

SYSTEMID="data.iplantcollaborative.org"
SHARED_DIR="eriksf/share"
TRACK_URL_BASE="https://de.iplantcollaborative.org/anon-files/iplant/home"

FULL_GDF=$1
DESCRIPTION=$2
SUBMITTER_EMAIL=$3

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
    (grep ^"#" "$FULL_GDF"; grep -v ^"#" "$FULL_GDF" | sort -k1,1 -k4,4n) >"$SORTED_GDF"
    STORECLASS="JBrowse/Store/SeqFeature/GFF3Tabix"
elif [[ $FILE_TYPE = "bed" ]]; then
    # sort the BED (using sort)
    sed -e "s/^[Cc][Hh][Rr]/Chr/g" "$FULL_GDF" | sort -k1,1 -k2,2n >"$SORTED_GDF"
    STORECLASS="JBrowse/Store/SeqFeature/BEDTabix"
elif [[ $FILE_TYPE = "vcf" ]]; then
    # sort the VCF (using vcftools)
    vcf-sort "$FULL_GDF" | sed -r "s/^([1-5CM])/Chr\1/g" >"$SORTED_GDF"
    STORECLASS="JBrowse/Store/SeqFeature/VCFTabix"
else
    echo "File type not recognized (supports gff, bed, or vcf)."
    exit 1
fi

# compress and index
bgzip "$SORTED_GDF"
tabix -p "$FILE_TYPE" "$GZIP_GDF"

# upload the files to iplant
/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEMID" -F "$GZIP_GDF" "$SHARED_DIR"
/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEMID" -F "$TABIX_GDF" "$SHARED_DIR"

# construct (and upload) a JBrowse config file referencing the GFF3 file
cat <<EOT >> "$JBROWSE_CONF"
[tracks.$NAME_GDF]
storeClass  = $STORECLASS
type        = JBrowse/View/Track/CanvasFeatures
category    = Community Data Tracks
key         = $DESCRIPTION
urlTemplate = $TRACK_URL_BASE/$SHARED_DIR/${SORTED_GDF}.gz
EOT

/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEMID" -F "$JBROWSE_CONF" "$SHARED_DIR"

# make share directory readable by anonymous
/usr/local/cyverse-cli/bin/files-pems-update -f -R -S "$SYSTEMID" -U anonymous -P READ "$SHARED_DIR"

# email araport@jcvi.org to notify of track upload
