# ---- Base image ----
FROM alpine:latest

# ---- Variables ----
ENV DISPLAY=:0
ENV VNC_PORT=5900
ENV NOVNC_PORT=8080
ENV NO_VNC_HOME=/usr/share/novnc

# ---- Install packages ----
RUN apk add --no-cache \
    x11vnc \
    xvfb \
    fluxbox \
    xterm \
    ttf-dejavu \
    mesa-gl \
    websockify \
    tini \
    bash \
    curl \
    supervisor

# ---- noVNC ----
RUN mkdir -p $NO_VNC_HOME \
    && curl -L https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz | tar xz --strip-components=1 -C $NO_VNC_HOME

# ---- VNC password ----
RUN mkdir -p /root/.vnc \
    && x11vnc -storepasswd 1234 /root/.vnc/passwd

# ---- Start script ----
RUN echo -e '#!/bin/sh\n\
# Start X server\n\
Xvfb :0 -screen 0 1024x768x16 &\n\
sleep 5\n\
# Start Fluxbox + Xterm\n\
fluxbox &\n\
xterm &\n\
# Start x11vnc\n\
x11vnc -forever -usepw -display :0 -rfbport $VNC_PORT &\n\
# Start noVNC\n\
websockify --web $NO_VNC_HOME $NOVNC_PORT localhost:$VNC_PORT' \
> /usr/local/bin/start_fluxbox.sh

RUN chmod +x /usr/local/bin/start_fluxbox.sh

# ---- Expose ports ----
EXPOSE $VNC_PORT $NOVNC_PORT

# ---- Entrypoint ----
ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/start_fluxbox.sh"]
