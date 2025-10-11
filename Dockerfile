FROM alpine:latest

# =========================
# 🧩 Installation des dépendances
# =========================
RUN apk add --no-cache \
    surf \
    tor \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    novnc \
    websockify \
    bash \
    tini

# =========================
# ⚙️ Configuration de Tor
# =========================
RUN mkdir -p /var/lib/tor && \
    chown tor /var/lib/tor && \
    echo "SOCKSPort 0.0.0.0:9050" > /etc/tor/torrc && \
    echo "Log notice stdout" >> /etc/tor/torrc && \
    echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc

# =========================
# ⚙️ Supervisor config inline
# =========================
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:tor]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/tor -f /etc/tor/torrc" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:xvfb]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/Xvfb :0 -screen 0 1280x800x24" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:fluxbox]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/fluxbox" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=:0" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:x11vnc]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/x11vnc -display :0 -nopw -forever -shared -rfbport 5900" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:websockify]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/websockify --web=/usr/share/novnc/ 8080 localhost:5900" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:surf]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/surf -s https://check.torproject.org" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=:0, all_proxy=socks5://127.0.0.1:9050, http_proxy=, https_proxy=" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf

# =========================
# 🧠 Démarrage via Tini + Supervisor
# =========================
EXPOSE 8080 9050
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
