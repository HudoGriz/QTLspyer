FROM docker.io/biocontainers/fastqc:v0.11.8dfsg-2-deb_cv1 AS fastqc

FROM docker.io/broadinstitute/picard:2.23.1 AS picard

FROM docker.io/broadinstitute/gatk:4.1.9.0 AS gatk

FROM docker.io/resolwebio/rnaseq:5.11.0 AS resolwebio
COPY --from=fastqc /usr/bin/fastqc .
COPY --from=picard /usr/picard /usr/picard
COPY --from=gatk /gatk /gatk

# Update keyserver
RUN apt-get update; exit 0
RUN yes | apt-get install gnupg2
RUN apt-key del "E298 A3A8 25C0 D65D FD57  CBB6 5171 6619 E084 DAB9"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN apt-get update

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libv8-dev \
    libssl-dev \
    liblapack-dev \
    liblapack3 \
    libopenblas-base \
    libopenblas-dev \
    gfortran

# copy necessary files
COPY QTLspyer ./QTLspyer
COPY /QTLspyer/shiny/renv.lock ./renv.lock

ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/kent/bedGraphToBigWig/:/opt/kent/bedToBigBed/:/opt/quinlan-lab/bedtools2/bin:/opt/babraham/fastqc/:/opt/ccb-jhu/hisat2/:/opt/smithlab/makedb/:/opt/hartleys/qorts/:/opt/samtools/samtools/:/opt/ncbi/sra-toolkit/bin:/opt/wehi/subread/bin:/opt/bbmap/bbmap/:/opt/ctl/cufflinks/bin:/opt/genialis/gotea/:/opt/broadinstitute/igvtools/:/opt/gmod/jbrowse/bin:/opt/griffithlab/regtools/build:/opt/deweylab/rsem/:/opt/combine-lab/salmon/bin:/opt/alexdobin/star/bin/Linux_x86_64:/opt/usadellab/trimmomatic/"

# install renv & restore packages
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::consent(provided = TRUE)'
RUN Rscript -e 'renv::restore()'

# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/QTLspyer/shiny', host = '0.0.0.0', port = 3838)"]

LABEL author="Blaz Vrhovsek"
