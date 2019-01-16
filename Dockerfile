FROM docker:18.06.1 as docker
FROM alpine:3.8

RUN set -ex; \
    apk update; \
    apk upgrade; \
    apk add --update \
        python3 \
        python3-dev \
        python2-dev \
        py3-pip \
        git \
        gcc \
        libffi \
        libffi-dev \
        musl-dev \
        make \
        openssl \
        openssl-dev

COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker

# Python3 requires a valid locale
#RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV PKG_CONFIG_PATH /usr/lib

RUN adduser -h /home/user -s /bin/bash -S user
WORKDIR /code/

RUN pip3 install --upgrade pip tox==2.1.1

ADD requirements.txt /code/
ADD requirements-dev.txt /code/
ADD .pre-commit-config.yaml /code/
ADD setup.py /code/
ADD tox.ini /code/
ADD compose /code/compose/
#README.md can be empty
ADD README.md /code/
RUN tox --notest

ADD . /code/
RUN chown -R user /code/

ENTRYPOINT ["/code/.tox/py36/bin/docker-compose"]
