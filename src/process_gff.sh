#!/bin/bash

set -euo pipefail
#set -x

SYSTEMID="data.iplantcollaborative.org"
SHARED_DIR="eriksf/share"
TRACK_URL_BASE="https://de.iplantcollaborative.org/anon-files/iplant/home"

FULL_GFF=$1
BASE_GFF=$(basename "$FULL_GFF")
NAME_GFF=${BASE_GFF%.*}
SORTED_GFF=$NAME_GFF.sorted.gff
GZIP_GFF=$SORTED_GFF.gz
TABIX_GFF=$GZIP_GFF.tbi
JBROWSE_CONF=$NAME_GFF.conf

# validate the gff file (using genometools)
gt gff3validator -typecheck so "$FULL_GFF"

# sort the gff (using genometools)
#gt gff3 -sortlines yes -tidy yes -retainids yes -addids no -checkids yes $FULL_GFF >$SORTED_GFF

# sort the gff (using sort)
(grep ^"#" "$FULL_GFF"; grep -v ^"#" "$FULL_GFF" | sort -k1,1 -k4,4n) >"$SORTED_GFF"

# compress and index
bgzip "$SORTED_GFF"
tabix -p gff "$GZIP_GFF"

# upload the files to iplant
/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEMID" -F "$GZIP_GFF" "$SHARED_DIR"
/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEMID" -F "$TABIX_GFF" "$SHARED_DIR"

# construct (and upload) a JBrowse config file referencing the GFF3 file
cat <<EOT >> "$JBROWSE_CONF"
[tracks.$NAME_GFF]
storeClass  = JBrowse/Store/SeqFeature/GFF3Tabix
type        = JBrowse/View/Track/CanvasFeatures
category    = Community Data Tracks
key         = $NAME_GFF
urlTemplate = $TRACK_URL_BASE/$SHARED_DIR/${SORTED_GFF}.gz
EOT

/usr/local/cyverse-cli/bin/files-upload -f -S "$SYSTEMID" -F "$JBROWSE_CONF" "$SHARED_DIR"

# make share directory readable by anonymous
/usr/local/cyverse-cli/bin/files-pems-update -f -R -S "$SYSTEMID" -U anonymous -P READ "$SHARED_DIR"
