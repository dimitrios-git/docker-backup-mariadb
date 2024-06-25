FROM mariadb:latest

RUN true \
    && apt update \
    && apt install -y \
        cron \
        tini \
    && rm -rf /var/lib/apt \
    && true

COPY ./entrypoint.sh /

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["tini", "/sbin/cron", "--", "-f"]
