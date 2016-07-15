FROM alpine:3.4
RUN apk add --update postfix ca-certificates bash
COPY docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]
