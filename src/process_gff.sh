#!/bin/sh

set -e

FULL_GFF=$1
BASE_GFF=$(basename "$FULL_GFF")
NAME_GFF=${BASE_GFF%.*}
SORTED_GFF=$NAME_GFF.sorted.gff

# validate the gff file (using genometools)
gt gff3validator -typecheck so "$FULL_GFF"

# sort the gff (using genometools)
#gt gff3 -sortlines yes -tidy yes -retainids yes -addids no -checkids yes $FULL_GFF >$SORTED_GFF

# sort the gff (using sort)
(grep ^"#" "$FULL_GFF"; grep -v ^"#" "$FULL_GFF" | sort -k1,1 -k4,4n) >"$SORTED_GFF"

# compress and index
bgzip "$SORTED_GFF"
tabix -p gff "$SORTED_GFF.gz"
