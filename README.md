### A forward-only SMTP server container

Uses postfix to forward mail from localhost to public SMTP servers

#### Usage example

Send a message via your Gmail account:

```console
$ docker run -d --name postfix \
	-e DOMAIN={your-domain} \
	-e SMTP_SERVER=smtp.gmail.com \
	-e SMTP_PORT=587 \
	-e LOGIN_EMAIL={your-gmail-here} \
	-e LOGIN_PASSWORD={your-password-here} \
	-e USE_TLS=1 gambitlabs/postfix:0.1

$ docker exec -it postfix /bin/bash

$ export TO_ADDR={an-email-address-here}
$ cat > my-message <<EOF
To: ${TO_ADDR}
From: ${LOGIN_EMAIL}
Subject: This is awesome!

Now I've managed to send an email from a docker container. Check!
EOF

$ sendmail ${TO_ADDR} < my-message
```

There's one more option: `USE_PLAIN_ONLY`.
Set that option to true when the SMTP server only can handle `PLAIN` messages.

### LICENSE

MIT
