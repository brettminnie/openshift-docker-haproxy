ARG BUILD_IMAGE="almalinux:8-minimal"
FROM ${BUILD_IMAGE}

COPY ./container_resources/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN microdnf update -y && \
    microdnf install -y epel-release && \
    microdnf install haproxy supervisor rsyslog -y && \
    mkdir /config && \
    microdnf clean all && \
    rm -rf /tmp/* && \
    rm -rf /usr/local/share/man/* && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir /etc/systemd/system/haproxy.service.d && \
    echo "[Service]" > /etc/systemd/system/haproxy.service.d/limits.conf && \
    echo "LimitNOFILE=500000" >> /etc/systemd/system/haproxy.service.d/limits.conf

COPY container_resources/etc/supervisord.conf /etc/supervisord.conf
COPY container_resources/etc/rsyslog.conf /etc/rsyslog.conf
COPY container_resources/etc/rsyslog.d/logging.conf /etc/rsyslog.d/logging.conf
COPY container_resources/config/ /config/

VOLUME /config
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash", "-c", "/usr/bin/supervisord",  "-c", "/etc/supervisord.conf"]
