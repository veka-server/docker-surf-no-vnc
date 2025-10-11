FROM alpine:latest

# =========================
# 🧩 Installation des dépendances légères
# =========================
RUN apk add --no-cache \
    falkon \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    novnc \
    websockify \
    bash \
    tini

# =========================
# ⚙️ Configuration Supervisor (inline)
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
    echo "[program:falkon]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/falkon --no-remote --profile /root/.config/falkon/profile --no-session --start-maximized --url https://check.torproject.org" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=:0, QTWEBENGINE_CHROMIUM_FLAGS=--proxy-server=socks5://tor:9050 --disable-javascript" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf

# =========================
# 🚀 Démarrage via Tini + Supervisor
# =========================
EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
