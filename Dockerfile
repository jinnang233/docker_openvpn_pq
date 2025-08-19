# Dockerfile
FROM docker.m.daocloud.io/debian:13
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install --no-install-recommends -y openssl openvpn bridge-utils && \
    rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y iproute2 iptables

COPY server.ext /server.ext
COPY client.ext /client.ext

# Copy the certificate generation script
COPY gen_cert.sh /gen_cert.sh
RUN chmod +x /gen_cert.sh

COPY gen_client.sh /gen_client.sh
RUN chmod +x /gen_client.sh


# Copy serverstart.sh script
COPY serverstart.sh /serverstart.sh
RUN chmod +x /serverstart.sh

RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200 && chmod 600 /dev/net/tun

# start server
CMD ["/serverstart.sh"]
