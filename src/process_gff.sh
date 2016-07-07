#!/bin/sh

FULL_GFF=$1
BASE_GFF=$(basename $FULL_GFF)
NAME_GFF=${BASE_GFF%.*}
SORTED_GFF=$NAME_GFF.sorted.gff

# sort the gff
gt gff3 -sortlines yes -tidy yes -retainids yes -addids no -checkids yes $FULL_GFF >$SORTED_GFF

# compress and index
bgzip $SORTED_GFF
tabix -p gff $SORTED_GFF.gz
