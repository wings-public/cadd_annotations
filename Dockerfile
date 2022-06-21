FROM snakemake/snakemake:latest
ENV CADD_DATA /cadd/repo/CADD_V_1.6
WORKDIR $CADD_DATA
COPY . $CADD_DATA
RUN apt-get -qq update && apt-get -qq -y install wget vim git
CMD tail -f /dev/null
