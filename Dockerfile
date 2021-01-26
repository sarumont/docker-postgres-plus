# Based on https://github.com/walm/docker-pgtap/blob/master/Dockerfile
FROM postgres:latest

ENV PLV8_VERSION=2.3.15 \
    PLV8_SHASUM="8a05f9d609bb79e47b91ebc03ea63b3f7826fa421a0ee8221ee21581d68cb5ba v2.3.15.tar.gz"

RUN apt-get update \
      && apt-get install -y \
        build-essential \
        ca-certificates \
        gettext-base \
        git-core \
        curl \
    # required by pgtap
        libv8-dev \
        postgresql-server-dev-$PG_MAJOR \ 
        ninja-build libtinfo5 libglib2.0-dev libc++-dev libc++abi-dev \
    && apt-get install --fix-missing \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install pg_prove
RUN curl -LO http://xrl.us/cpanm \
      && chmod +x cpanm \
      && ./cpanm TAP::Parser::SourceHandler::pgTAP

# install pgtap
RUN git clone git://github.com/theory/pgtap.git \
      && cd pgtap \
      && make \
      && make install \
      && make clean

# install plv8
RUN mkdir -p /tmp/build \
  && curl -o /tmp/build/v${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz"

WORKDIR /tmp/build
RUN echo ${PLV8_SHASUM} | sha256sum -c
RUN tar -xzf /tmp/build/v${PLV8_VERSION}.tar.gz -C /tmp/build/

RUN git config --global user.email "ci@example.com" && git config --global user.name "CI"

WORKDIR /tmp/build/plv8-${PLV8_VERSION}
RUN make && make install
RUN apt-get clean && apt-get remove -y ${buildDependencies} && apt-get autoremove -y && rm -rf /tmp/build /var/lib/apt/lists/*
