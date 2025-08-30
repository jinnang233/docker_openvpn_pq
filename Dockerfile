FROM docker.m.daocloud.io/debian:13
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade && apt-get install --no-install-recommends -y openssl openvpn bridge-utils iproute2 iptables && rm -rf /var/lib/apt/lists/*

COPY server.ext /server.ext
COPY client.ext /client.ext

COPY gen_cert.sh /gen_cert.sh
RUN chmod +x /gen_cert.sh

COPY gen_client.sh /gen_client.sh
RUN chmod +x /gen_client.sh
COPY serverstart.sh /serverstart.sh
RUN chmod +x /serverstart.sh

RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200 && chmod 600 /dev/net/tun 

CMD ["/serverstart.sh"]


