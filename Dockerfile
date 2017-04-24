# docker build --rm -t aculich/rockyter .

FROM jupyter/datascience-notebook

MAINTAINER Aaron Culich <aculich@berkeley.edu>

USER root

ARG RSTUDIO_VERSION
ARG PANDOC_TEMPLATES_VERSION
ENV PANDOC_TEMPLATES_VERSION ${PANDOC_TEMPLATES_VERSION:-1.18}

## Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin:$PATH

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    git \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    python-setuptools \
    sudo \
    wget \
  && RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  && wget -q http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && dpkg -i rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb

RUN ln -sf /bin/tar /bin/gtar ; \
    ln -sf /opt/conda/bin/R /usr/bin/R ; \
    ln -sf /opt/conda/lib/R /usr/lib/R ; \
    ln -sf /usr/lib/rstudio-server /usr/lib/rstudio ; \
    mkdir -p /usr/share/R/doc
#RUN echo /opt/conda/lib/R/lib >> /etc/ld.so.conf.d/conda.conf ; \
#     ldconfig

USER $NB_USER

RUN pip install git+https://github.com/aculich/nbserverproxy; \
  jupyter serverextension enable --py nbserverproxy


RUN pip install git+https://github.com/aculich/nbrsessionproxy; \
  jupyter serverextension enable  --py --sys-prefix nbrsessionproxy; \
  jupyter nbextension     install --py --sys-prefix nbrsessionproxy; \
  jupyter nbextension     enable  --py --sys-prefix nbrsessionproxy


