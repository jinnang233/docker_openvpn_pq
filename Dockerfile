ARG DEBIAN_IMAGE=docker.m.daocloud.io/debian:13
FROM ${DEBIAN_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        bridge-utils \
        iproute2 \
        iptables \
        openssl \
        openvpn \
    && rm -rf /var/lib/apt/lists/*

COPY server.conf /server.conf
COPY server.conf /etc/openvpn/server.conf
COPY server.ext /server.ext
COPY client.ext /client.ext
COPY gen_cert.sh /gen_cert.sh
COPY gen_client.sh /gen_client.sh
COPY serverstart.sh /serverstart.sh

RUN chmod +x /gen_cert.sh /gen_client.sh /serverstart.sh

CMD ["/serverstart.sh"]


