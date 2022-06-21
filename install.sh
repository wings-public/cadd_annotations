#!/bin/bash

usage="$(basename "$0") [-g <GRCh37,GRCh38>]

where:
    -g  GRCh37,GRCh38
    "

unset OPTARG
unset OPTIND
export LC_ALL=C

GENOMEBUILD="GRCh38"

BASEDIR=$(dirname "$SCRIPT")

while getopts g: option
do
case "${option}"
in
g) BUILD=${OPTARG};;
\?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
esac
done


if [[ $BUILD != "GRCh37" &&  $BUILD != "GRCh38" && $BUILD != "GRCh37,GRCh38" ]]; then
    echo "Unknown build input provided for $BUILD. Please provide GRCh37 or GRCh38."
    echo $usage
    exit 1
fi

HG19="install.auto.hg19.sh"
HG38="install.auto.hg38.sh"
SCRIPT1="$BASEDIR/$HG19"
SCRIPT2="$BASEDIR/$HG38"

if [[ $BUILD == "GRCh37" ]];then
    echo $SCRIPT1
    bash "$SCRIPT1"
fi

if [[ $BUILD == "GRCh38" ]];then
    bash "$SCRIPT2"
    echo $SCRIPT2
fi

if [[ $BUILD == "GRCh37,GRCh38" ]];then
   echo $SCRIPT1
   echo $SCRIPT2
   bash "$SCRIPT1"
   bash "$SCRIPT2"
fi
