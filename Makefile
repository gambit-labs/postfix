
AUTHOR=gambitlabs
VERSION=v0.1.0

build:
	docker build -t ${AUTHOR}/postfix:${VERSION} .
