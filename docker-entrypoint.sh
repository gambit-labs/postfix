#!/bin/bash

# References:
# http://www.postfix.org/SASL_README.html#server_sasl
# http://tecadmin.net/ways-to-send-email-from-linux-command-line/
# https://www.rootusers.com/configure-postfix-to-forward-mail-to-a-central-relay-server/
# https://easyengine.io/tutorials/linux/ubuntu-postfix-gmail-smtp/

if [[ -z ${DOMAIN} || -z ${SMTP_SERVER} ]]; then
	echo "The DOMAIN and SMTP_SERVER variables are required."
	echo "Exiting because at least one of them is unset."
	exit 1
fi

SMTP_PORT=${SMTP_PORT:-25}
LOGIN_EMAIL=${LOGIN_EMAIL:-}
LOGIN_PASSWORD=${LOGIN_PASSWORD:-}
USE_TLS=${USE_TLS:-0}
USE_PLAIN_ONLY=${USE_PLAIN_ONLY:-0}
POSTFIX_FOREGROUND=${POSTFIX_FOREGROUND:-1}

cat >> /etc/postfix/main.cf <<EOF
myhostname = mail.${DOMAIN}
mydomain = ${DOMAIN}
myorigin = ${DOMAIN}
mynetworks = 127.0.0.1/8 [::1]/128
relayhost = [${SMTP_SERVER}]:${SMTP_PORT}
EOF

if [[ ! -z ${LOGIN_EMAIL} && ! -z ${LOGIN_PASSWORD} ]]; then

	echo "[${SMTP_SERVER}]:${SMTP_PORT}    ${LOGIN_EMAIL}:${LOGIN_PASSWORD}" > /etc/postfix/sasl_passwd

	cat >> /etc/postfix/main.cf <<EOF
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
EOF

	if [[ ${USE_TLS} == 1 ]]; then

		cat >> /etc/postfix/main.cf <<EOF
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_use_tls = yes
EOF
	fi

	if [[ ${USE_PLAIN_ONLY} == 1 ]]; then

		cat >> /etc/postfix/main.cf <<EOF
broken_sasl_auth_clients = yes
smtp_sasl_mechanism_filter = plain
EOF
	fi
fi

chmod 400 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
postfix start

if [[ ${POSTFIX_FOREGROUND} == 1 ]]; then
	while true; do
		sleep 3600
	done
fi
