#!/bin/bash

set -euo pipefail
set -x

# Usage info
show_help() {
    cat <<EOF
Usage: ${0##*/} [-hv] [-d DESC] [GDF_FILE]...
Deploy genomic data format file GDF_FILE (gff, bed, or vcf) as a community track
on the Araport JBrowse instance.

    -h        display this help and exit
    -v        show the program version
    -d DESC   Brief description of the track data
EOF
}

# Process command line options
OPTIND=1
while getopts "hvd:e:" OPT; do
    case "$OPT" in
        h)
            show_help
            exit 0
            ;;
        v)
            echo "$(basename "$0") version {{tool_version}}"
            exit 0
            ;;
        d)
            description=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

# check for GDF file
if [[ $# -ne 1 ]]; then
    echo "Please specify a GFF, BED, or VCF file."
    exit 1
fi

# check for description
if [[ -z "${description// }" ]]; then
    echo "Please specify a track description (-d)."
    exit 1
fi

gdf_file=$1

echo "File: $gdf_file"
echo "Description: $description"
