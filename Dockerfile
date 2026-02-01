FROM snakemake/snakemake:latest
ENV CADD_DATA=/cadd/repo/CADD_V_1.6
SHELL ["/bin/bash", "-c"]
RUN dpkg --configure -a && rm -f /var/lib/dpkg/lock* && apt-get -qq update && apt-get -qq -y --no-install-recommends install wget vim git
WORKDIR $CADD_DATA
COPY . $CADD_DATA
CMD tail -f /dev/null
