#!/bin/bash

set -euo pipefail
#set -x

IMAGENAME="{{IMAGENAME}}"

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

die() {
	echo "$1" 1>&2
	exit 1
}

realpath() {
    echo "$(cd "$(dirname "$1")"; pwd)"
}

# Process command line options
OPTIND=1
while getopts "hvd:" OPT; do
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

# check for docker install
docker info > /dev/null || die "Docker is not installed. Exiting."

gdf_path=$(realpath "$1")
gdf_file=$(basename "$1")

docker run -v "${HOME}/.agave:/root/.agave" -v "${gdf_path}:/data" "${IMAGENAME}:latest" "$gdf_file" "$description"
