FROM buildpack-deps:bullseye AS isolate
RUN apt-get update && \
    apt-get install -y --no-install-recommends git libcap-dev && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/envicutor/isolate.git /tmp/isolate/ && \
    cd /tmp/isolate && \
    git checkout af6db68042c3aa0ded80787fbb78bc0846ea2114 && \
    make -j$(nproc) install && \
    rm -rf /tmp/*

FROM node:18-bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg-reconfigure -p critical dash
RUN apt-get update && \
    apt-get install -y libxml2 gnupg tar coreutils util-linux libc6-dev \
    binutils build-essential locales libpcre3-dev libevent-dev libgmp3-dev \
    libncurses6 libncurses5 libedit-dev libseccomp-dev rename procps python3 \
    libreadline-dev libblas-dev liblapack-dev libpcre3-dev libarpack2-dev \
    libfftw3-dev libglpk-dev libqhull-dev libqrupdate-dev libsuitesparse-dev \
    libsundials-dev libpcre2-dev libcap-dev git && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -M piston
COPY --from=isolate /usr/local/bin/isolate /usr/local/bin
COPY --from=isolate /usr/local/etc/isolate /usr/local/etc/isolate

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

WORKDIR /piston

RUN mkdir -p /piston/packages

# Install API dependencies
COPY api/package.json api/package-lock.json api/
RUN cd api && npm install

# Install CLI dependencies
COPY cli/package.json cli/package-lock.json cli/
RUN cd cli && npm install

# Copy sources
COPY api api
COPY cli cli
COPY packages packages

# Prepare and run package installation
COPY install_packages.sh .
RUN chmod +x install_packages.sh

# Start API in background, wait for it to be ready, run install script, then kill API
RUN (cd api && node src/index.js &) && \
    sleep 10 && \
    ./install_packages.sh && \
    pkill -f "node src/index.js" || true

# Cleanup
RUN rm install_packages.sh

EXPOSE 2000
CMD ["node", "api/src/index.js"]
