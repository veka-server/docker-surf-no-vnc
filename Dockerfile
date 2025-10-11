FROM alpine:latest

# =========================
# Installer dépendances
# =========================
RUN apk add --no-cache \
    bash \
    fluxbox \
    xterm \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    tini

# =========================
# Création script de démarrage
# =========================
RUN mkdir -p /root/.vnc \
    && echo '#!/bin/sh' > /root/.vnc/xstartup \
    && echo 'fluxbox &' >> /root/.vnc/xstartup \
    && echo 'xterm &' >> /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

# =========================
# Variables d'environnement
# =========================
ENV DISPLAY=:0
EXPOSE 8080 5900

# =========================
# Lancement Xvfb, xstartup et noVNC
# =========================
CMD Xvfb :0 -screen 0 1024x768x16 & \
    sleep 1 && \
    /root/.vnc/xstartup & \
    x11vnc -display :0 -nopw -forever -shared -rfbport 5900 -listen 0.0.0.0 & \
    websockify --web=/usr/share/novnc/ 8080 localhost:5900
