FROM hypriot/rpi-alpine-scratch

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add curl fcron@testing bash

COPY *.sh /
RUN chmod 755 /run.sh
CMD /run.sh
