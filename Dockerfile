FROM alpine:latest

# =========================
# Dépendances de base + Firefox
# =========================
RUN apk add --no-cache \
    firefox-esr \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    novnc \
    websockify \
    bash \
    tini \
    gtk+3.0 \
    dbus \
    ttf-freefont \
    fontconfig \
    alsa-lib \
    libXt \
    libXrender \
    libXcomposite \
    libXdamage \
    libXrandr \
    libxkbcommon

# =========================
# Supervisor configuration
# =========================
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    \
    echo "[program:xvfb]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/Xvfb :0 -screen 0 1280x800x24" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    \
    echo "[program:fluxbox]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/fluxbox" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=:0" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    \
    echo "[program:x11vnc]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/x11vnc -display :0 -nopw -forever -shared -rfbport 5900" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    \
    echo "[program:websockify]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/websockify --web=/usr/share/novnc/ 8080 localhost:5900" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    \
    echo "[program:firefox]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/firefox-esr --no-remote --profile /root/.mozilla/firefox --new-instance https://check.torproject.org" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=':0',MOZ_DISABLE_CONTENT_SANDBOX=1,ALL_PROXY='socks5://tor:9050'" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf

EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
