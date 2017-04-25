FROM na4lapy/swift:base
MAINTAINER Andrzej Butkiewicz <scoot@wp.pl>

COPY ./na4lapyapi.deb /
RUN dpkg -i na4lapyapi.deb

ENV LD_LIBRARY_PATH=/usr/lib/swift/linux
ENTRYPOINT /usr/local/na4lapyapi/Server
