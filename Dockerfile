FROM alpine:3.4
RUN apk add --update postfix ca-certificates bash
COPY postfix-entrypoint.sh /
CMD ["/postfix-entrypoint.sh"]
