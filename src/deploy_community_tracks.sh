#!/bin/bash

set -euo pipefail
#set -x

# Usage info
show_help() {
    cat <<EOF
Usage: ${0##*/} [-hv] [-d DESC] [-e EMAIL] [GFF_FILE]...
Deploy GFF_FILE as a community track on the Araport JBrowse instance.

    -h        display this help and exit
    -v        show the program version
    -d DESC   Brief description of the track data
    -e EMAIL  Email address of submitter
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
            echo "$(basename "$0") version 0.0.1"
            exit 0
            ;;
        d)
            description=$OPTARG
            ;;
        e)
            submitter_email=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

# check for GFF file
if [[ $# -ne 1 ]]; then
    echo "Please specify a GFF file."
    exit 1
fi

# check for description
if [[ -z "${description// }" ]]; then
    echo "Please specify a track description (-d)."
    exit 1
fi

# check for submitter email address
if [[ -z "${submitter_email// }" ]]; then
    echo "Please specify a email address (-e)."
    exit 1
fi

gff_file=$1

echo "File: $gff_file"
echo "Description: $description"
echo "Submitter Email: $submitter_email"
