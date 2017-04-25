FROM swift:3.1
MAINTAINER Andrzej Butkiewicz <scoot@wp.pl>

RUN apt-get -q update && apt-get -q install -y postgresql libpq-dev

COPY ./na4lapyapi.deb /
RUN dpkg -i na4lapyapi.deb

RUN /usr/sbin/groupadd -g 1001 na4lapy
RUN /usr/sbin/useradd --create-home --home-dir /home/na4lapy --shell /bin/bash -u 1002 -g 1001 na4lapy

USER na4lapy
ENV HOME /home/na4lapy
WORKDIR /home/na4lapy

ENV LD_LIBRARY_PATH=/usr/lib/swift/linux
ENTRYPOINT /usr/local/na4lapyapi/Server
