FROM debian:buster-slim
RUN apt-get update
RUN apt-get install -y curl perl dnsmasq

COPY dnsmasq.conf blocked_host[s] pfsense_block_source.lis[t] /etc/
COPY adblockgen.pl /root
WORKDIR /etc
RUN perl /root/adblockgen.pl

# Mount your host files to those points
# addn-hosts=/etc/blocked_hosts
# addn-hosts=/etc/user_hosts

RUN echo "user=root" >> /etc/dnsmasq.conf
ENTRYPOINT ["dnsmasq","-k","--port=5353"]
