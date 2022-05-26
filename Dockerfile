FROM docker.io/broadinstitute/picard:2.27.1 AS picard
FROM docker.io/broadinstitute/gatk:4.2.6.1 AS gatk

LABEL author="Blaz Vrhovsek"

COPY --from=picard /usr/picard /usr/picard

ENV DEBIAN_FRONTEND noninteractive

# Update keyserver and packages
RUN apt-get update; exit 0
RUN apt-get install -y gnupg2
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 8B57C5C2836F4BEB
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
    gfortran \
    snakemake \
    fastqc \
    bwa

# R
# GATK - /opt/miniconda/envs/gatk/bin/R
ENV alias R=/usr/lib/R/bin/R

RUN apt -y remove r-base
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
RUN apt -y update && apt -y install r-base r-base-dev

# pip
RUN pip install pyyaml plumbum

# copy necessary files
WORKDIR /
COPY QTLspyer /QTLspyer
WORKDIR /QTLspyer/shiny
# COPY /QTLspyer/shiny/renv.lock ./renv.lock

RUN /usr/lib/R/bin/Rscript -e 'install.packages("renv", repos = "http://cran.us.r-project.org")'
RUN /usr/lib/R/bin/Rscript -e 'renv::consent(provided = TRUE)'
RUN /usr/lib/R/bin/Rscript -e 'renv::restore()'

# install renv & restore packages
# RUN conda update -y conda
# RUN conda install -y -c r r-lattice
# RUN conda install -y gxx_linux-64
WORKDIR /

# expose port
EXPOSE 3838

# run app on container start
CMD ["/usr/lib/R/bin/R", "-e", "shiny::runApp('/QTLspyer/shiny', host = '0.0.0.0', port = 3838)"]
