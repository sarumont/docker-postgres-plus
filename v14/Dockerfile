# Based on https://github.com/walm/docker-pgtap/blob/master/Dockerfile
# And on https://github.com/clkao/docker-postgres-plv8
FROM postgres:14 as build

ENV PLV8_VERSION=2.3.15 \
    PLV8_SHASUM="8a05f9d609bb79e47b91ebc03ea63b3f7826fa421a0ee8221ee21581d68cb5ba v2.3.15.tar.gz" \
    buildDependencies="build-essential \
    ca-certificates \
    gettext-base \
    git-core \
    curl \
    python \
    # required by pgtap
    # libv8-dev \                                           # this seems to f*** plv8 up, does not affect pgtap !
    postgresql-server-dev-$PG_MAJOR \
    ninja-build libglib2.0-dev libc++-dev libc++abi-dev"\
    runtimeDependencies="libc++1 \
    libtinfo5 \
    libc++abi1"

RUN apt-get update \
      && apt-get install -y --no-install-recommends ${buildDependencies} ${runtimeDependencies} \
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
RUN make static \
  && make install \
  && strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so \
  && rm -rf /root/.vpython_cipd_cache /root/.vpython-root \
  && rm -rf /tmp/build
RUN apt-get clean && apt-get remove -y ${buildDependencies} && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# PG image
FROM postgres:14

ENV PLV8_VERSION=2.3.15

ENV deps="curl \
    ca-certificates \
    libc++1 \
    libtinfo5 \
    libc++abi1"

RUN apt-get update \
      && apt-get install -y --no-install-recommends ${deps} \
    && apt-get install --fix-missing \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install pg_prove
RUN curl -LO http://xrl.us/cpanm \
      && chmod +x cpanm \
      && ./cpanm TAP::Parser::SourceHandler::pgTAP

COPY --from=build /usr/share/postgresql/${PG_MAJOR}/extension/pgtap* /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=build /usr/share/postgresql/${PG_MAJOR}/extension/plls* /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=build /usr/share/postgresql/${PG_MAJOR}/extension/plcoffee* /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=build /usr/share/postgresql/${PG_MAJOR}/extension/plv8* /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=build /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so
