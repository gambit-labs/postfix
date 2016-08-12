#!/bin/bash

# References:
# http://www.postfix.org/SASL_README.html#server_sasl
# http://tecadmin.net/ways-to-send-email-from-linux-command-line/
# https://www.rootusers.com/configure-postfix-to-forward-mail-to-a-central-relay-server/
# https://easyengine.io/tutorials/linux/ubuntu-postfix-gmail-smtp/

if [[ -z ${POSTFIX_DOMAIN} || -z ${POSTFIX_SMTP_SERVER} ]]; then
	echo "The POSTFIX_DOMAIN and POSTFIX_SMTP_SERVER variables are required."
	echo "Exiting because at least one of them is unset."
	exit 1
fi

POSTFIX_SMTP_PORT=${POSTFIX_SMTP_PORT:-25}
POSTFIX_LOGIN_EMAIL=${POSTFIX_LOGIN_EMAIL:-}
POSTFIX_LOGIN_PASSWORD=${POSTFIX_LOGIN_PASSWORD:-}
POSTFIX_USE_TLS=${POSTFIX_USE_TLS:-0}
POSTFIX_USE_PLAIN_ONLY=${POSTFIX_USE_PLAIN_ONLY:-0}
POSTFIX_FOREGROUND=${POSTFIX_FOREGROUND:-1}

cat >> /etc/postfix/main.cf <<EOF
myhostname = mail.${POSTFIX_DOMAIN}
mydomain = ${POSTFIX_DOMAIN}
myorigin = ${POSTFIX_DOMAIN}
mynetworks = 127.0.0.1/8 [::1]/128
relayhost = [${POSTFIX_SMTP_SERVER}]:${POSTFIX_SMTP_PORT}
EOF

if [[ ! -z ${POSTFIX_LOGIN_EMAIL} && ! -z ${POSTFIX_LOGIN_PASSWORD} ]]; then

	echo "[${POSTFIX_SMTP_SERVER}]:${POSTFIX_SMTP_PORT}    ${POSTFIX_LOGIN_EMAIL}:${POSTFIX_LOGIN_PASSWORD}" > /etc/postfix/sasl_passwd

	cat >> /etc/postfix/main.cf <<EOF
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
EOF

	if [[ ${POSTFIX_USE_TLS} == 1 ]]; then

		cat >> /etc/postfix/main.cf <<EOF
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_use_tls = yes
EOF
	fi

	if [[ ${POSTFIX_USE_PLAIN_ONLY} == 1 ]]; then

		cat >> /etc/postfix/main.cf <<EOF
broken_sasl_auth_clients = yes
smtp_sasl_mechanism_filter = plain
EOF
	fi
fi

chmod 400 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

postfix_usage() {
	cat <<-EOF
	Supported postfix variables and their defaults:
	 - POSTFIX_DOMAIN: Mandatory. Which domain postfix should pretend to send from.
	 - POSTFIX_SMTP_SERVER: Mandatory. The smtp server postfix should forward mail to.
	 - POSTFIX_SMTP_PORT=${POSTFIX_SMTP_PORT}: The port of the smtp server.
	 - POSTFIX_LOGIN_EMAIL=${POSTFIX_LOGIN_EMAIL}: The email address that should be used for login to the server.
	 - POSTFIX_LOGIN_PASSWORD=${POSTFIX_LOGIN_PASSWORD}: The password that should be used for login to the server.
	 - POSTFIX_USE_TLS=${POSTFIX_USE_TLS}: If tls should be used.
	 - POSTFIX_USE_PLAIN_ONLY=${POSTFIX_USE_PLAIN_ONLY}: Makes postfix authenticate with the server via the PLAIN method. 
	 - POSTFIX_FOREGROUND=${POSTFIX_FOREGROUND}: If this script should loop endlessly after postfix is started.

	postfix version: $(apk info postfix | head -1 | awk '{print $1}' | cut -d- -f2)
	EOF
}


if [[ $# == 0 ]]; then

	postfix start

	if [[ ${POSTFIX_FOREGROUND} == 1 ]]; then
		while true; do sleep 3600; done
	fi

elif [[ $# == 1 && $1 == "help" || $1 == "usage" ]]; then
	postfix_usage
else
	exec $@
fi
