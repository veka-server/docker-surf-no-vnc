FROM alpine:latest

RUN apk add --no-cache \
    x11vnc \
    xvfb \
    fluxbox \
    xterm \
    novnc \
    websockify \
    bash \
    tini

ENV DISPLAY=:1

EXPOSE 8080 5900

CMD Xvfb $DISPLAY -screen 0 1024x768x16 & \
    sleep 1 && \
    fluxbox & \
    xterm & \
    x11vnc -display $DISPLAY -forever -nopw -create & \
    websockify 8080 localhost:5900
