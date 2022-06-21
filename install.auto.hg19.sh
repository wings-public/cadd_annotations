#!/bin/bash

set -e

echo "CADD-v1.6 (c) University of Washington, Hudson-Alpha Institute for Biotechnology and Berlin Institute of Health 2013-2020. All rights reserved."
echo ""

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

cd $BASEDIR

# check whether conda and snakemake are available

if [ "$(type conda)" == '' ]
then
    echo 'Conda seems not to be available. Are you sure conda is installed and available in the current $PATH ?';
    exit 1;
fi

if [ "$(type snakemake)" == '' ]
then
    echo 'Snakemake seems not to be available. Are you sure snakemake is installed and available in the current $PATH ?';
    exit 1;
fi

echo "The following questions will quide you through selecting the files and dependencies needed for CADD."
echo "After this, you will see an overview of the selected files before the download and installation starts."
echo "Please note, that for successfully running CADD locally, you will need the conda environment and at least one set of annotations."
echo ""

# ask which parts of CADD the user wants to install
ENV=true
GRCh37=true
GRCh38=false

if [ "$GRCh37" = false ] && [ "$GRCh38" = false ]
then
    echo "You have choosen to not install any of the available CADD models. Discontinuing installation.";
    exit 0;
fi

ANNOTATIONS=true
PRESCORE=true

if [ "$PRESCORE" = true ]
then
    INCANNO=true
    NOANNO=true
    INDELS=true
fi

### FILE CONFIGURATION
DOWNLOAD_LOCATION="https://krishna.gs.washington.edu/download/CADD"

ANNOTATION_GRCh37="$DOWNLOAD_LOCATION/v1.6/GRCh37/annotationsGRCh37_v1.6.tar.gz"
ANNOTATION_GRCh37_MD5="$DOWNLOAD_LOCATION/v1.6/GRCh37/MD5SUMs"
PRESCORE_GRCh37="$DOWNLOAD_LOCATION/v1.6/GRCh37/whole_genome_SNVs.tsv.gz"
PRESCORE_INCANNO_GRCh37="$DOWNLOAD_LOCATION/v1.6/GRCh37/whole_genome_SNVs_inclAnno.tsv.gz"
PRESCORE_GRCh37_INDEL="$DOWNLOAD_LOCATION/v1.6/GRCh37/InDels.tsv.gz"
PRESCORE_INCANNO_GRCh37_INDEL="$DOWNLOAD_LOCATION/v1.6/GRCh37/InDels_inclAnno.tsv.gz"

### OVERVIEW SELECTION

echo ""
echo "The following will be loaded: (disk space occupied)"

if [ "$ENV" = true ]
then
    echo " - Setup of the virtual environments including all dependencies for CADD v1.6 (10 GB)."
fi

if [ "$GRCh37" = true ]
then
    if [ "$ANNOTATIONS" = true ]
    then
        echo " - Download CADD annotations for GRCh37-v1.6 (121 GB)"
    fi

    if [ "$PRESCORE" = true ]
    then
        if [ "$INCANNO" = true ]
        then
            echo " - Download prescored SNV inclusive annotations for GRCh37-v1.6 (248 GB)"
            if [ "$INDELS" = true ]
            then
                echo " - Download prescored InDels inclusive annotations for GRCh37-v1.6 (3.4 GB)"
            fi
        fi
        if [ "$NOANNO" = true ]
        then
            echo " - Download prescored SNV (without annotations) for GRCh37-v1.6 (78 GB)"
            if [ "$INDELS" = true ]
            then
                echo " - Download prescored InDels (without annotations) for GRCh37-v1.6 (0.6 GB)"
            fi
        fi
    fi
fi

CHOICE=true

### INSTALLATION

if [ "$ENV" = true ]
then
    echo "Setting up virtual environments for CADD v1.6"
    snakemake test/input.tsv.gz --use-conda --conda-create-envs-only --conda-prefix envs \
        --cores 1 --configfile config/config_GRCh37_v1.6.yml --snakefile Snakefile
fi

# download a file and it index and check both md5 sums
function download_variantfile()
{
    echo $1
    wget --tries 10000 -c $2
    wget -c $2.tbi
    wget $2.md5
    wget $2.tbi.md5
    md5sum -c *.md5
    rm *.md5
}

if [ "$GRCh37" = true ]
then
    if [ "$ANNOTATIONS" = true ]
    then
        echo "Downloading CADD annotations for GRCh37-v1.6 (121 GB)"
        mkdir -p data/annotations/
        cd data/annotations/
        wget --tries 10000 -c ${ANNOTATION_GRCh37} -O annotationsGRCh37_v1.6.tar.gz
	wget -c ${ANNOTATION_GRCh37_MD5} -O MD5SUMs
	cat MD5SUMs | grep "annotationsGRCh37_v1.6.tar.gz" > annotationsGRCh37_v1.6.tar.gz.md5
        #wget ${ANNOTATION_GRCh37}.md5 -O annotationsGRCh37_v1.6.tar.gz.md5
        md5sum -c annotationsGRCh37_v1.6.tar.gz.md5
        echo "Unpacking CADD annotations for GRCh37-v1.6"
        tar -zxf annotationsGRCh37_v1.6.tar.gz
        rm annotationsGRCh37_v1.6.tar.gz
        rm annotationsGRCh37_v1.6.tar.gz.md5
	rm MD5SUMs
        cd $OLDPWD
    fi

    if [ "$PRESCORE" = true ]
    then
        if [ "$NOANNO" = true ]
        then
            mkdir -p data/prescored/GRCh37_v1.6/no_anno/
            cd data/prescored/GRCh37_v1.6/no_anno/
            download_variantfile "Downloading prescored SNV without annotations for GRCh37-v1.6 (78 GB)" ${PRESCORE_GRCh37}
            if [ "$INDELS" = true ]
            then
                download_variantfile "Downloading prescored InDels without annotations for GRCh37-v1.6 (0.6 GB)" ${PRESCORE_GRCh37_INDEL}
            fi
            cd $OLDPWD
        fi

        if [ "$INCANNO" = true ]
        then
            mkdir -p data/prescored/GRCh37_v1.6/incl_anno/
            cd data/prescored/GRCh37_v1.6/incl_anno/
            download_variantfile "Downloading prescored SNV inclusive annotations for GRCh37-v1.6 (248 GB)" ${PRESCORE_INCANNO_GRCh37}
            if [ "$INDELS" = true ]
            then
                download_variantfile "Downloading prescored InDels inclusive annotations for GRCh37-v1.6 (3.4 GB)" ${PRESCORE_INCANNO_GRCh37_INDEL}
            fi
            cd $OLDPWD
        fi
    fi
fi
