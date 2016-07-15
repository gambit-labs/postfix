
AUTHOR=gambitlabs
VERSION=0.1

build:
	docker build -t ${AUTHOR}/postfix:${VERSION} .
