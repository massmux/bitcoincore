From debian
MAINTAINER Massimo Musumeci <go@massmux.com>

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Pars
ARG VERSION=0.21.0
ARG ARCH=x86_64
ARG OS=linux-gnu
ARG USER=bitcoind
ARG DIR=/data

# prerequisites
RUN    apt-get update
RUN    apt-get install -y \
        autoconf \
        build-essential \
        bc \
        curl \
        git \
        wget \
        jq \
        libssl-dev \
        libtool \
        net-tools \
        openssl \
        python-pip \
        pkg-config \
        procps \
        sed \
        vim \
        xxd

RUN pip install base58

RUN adduser --disabled-password \
            --home "$DIR/" \
            --gecos "" \
            "$USER"

# install core
# Ref binary url: https://bitcoincore.org/bin/
RUN 	cd /opt && wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION-$ARCH-$OS.tar.gz && \
	tar xzvf bitcoin-$VERSION-$ARCH-$OS.tar.gz && \
	mv /opt/bitcoin-$VERSION/bin/* /usr/bin/ && \
	chmod +x /usr/bin/bitcoin-cli && \
	chmod +x /usr/bin/bitcoind

# remove tarball
RUN	rm -f /opt/bitcoin-$VERSION-$ARCH-$OS.tar.gz

	
# install btcdeb
RUN    	cd /opt && \
    	wget https://github.com/bitcoin-core/btcdeb/archive/0.3.20.tar.gz && \
	tar -xzf 0.3.20.tar.gz && \
    	cd btcdeb-0.3.20 && \
	chmod +x ./autogen.sh && \
    	./autogen.sh && \
	chmod +x  ./configure && \
    	./configure && \
    	make && \
    	make install


ADD ./nodeworkdir /opt/nodeworkdir


# https://github.com/libbitcoin/libbitcoin-explorer/wiki
RUN cd /opt/nodeworkdir/utility && \
    wget https://github.com/libbitcoin/libbitcoin-explorer/releases/download/v3.2.0/bx-linux-x64-qrcode && \
    mv bx-linux-x64-qrcode bx && \
    chmod +x bx

# bizantino utility (thanks to Aglietti & Barnini)
RUN 	rm -Rf /usr/local/sbin && \
	mv /opt/nodeworkdir/utility /usr/local/sbin


USER $USER

# Prevents `VOLUME $DIR/.bitcoind/` being created as owned by `root`
RUN mkdir -p "$DIR/.bitcoin/"

# Expose volume containing all `bitcoind` data
VOLUME $DIR/.bitcoin/

#RUN mkdir -p /root/.bitcoin
#VOLUME /root/.bitcoin

EXPOSE 18443 18444

ENTRYPOINT ["bitcoind"]
