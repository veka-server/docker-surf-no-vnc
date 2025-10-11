FROM alpine:latest

RUN apk add --no-cache \
    falkon \
    xvfb \
    fluxbox \
    x11vnc \
    supervisor \
    novnc \
    websockify \
    bash \
    tini \
    ttf-freefont \
    fontconfig \
    dbus \
    alsa-lib \
    qt5-qtbase \
    qt5-qtmultimedia \
    qt5-qtwebengine

# Supervisor configuration
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:xvfb]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/Xvfb :0 -screen 0 1280x800x24" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "[program:fluxbox]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/fluxbox" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=:0" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "[program:x11vnc]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/x11vnc -display :0 -nopw -forever -shared -rfbport 5900" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "[program:websockify]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/websockify --web=/usr/share/novnc/ 8080 localhost:5900" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "[program:falkon]" >> /etc/supervisord.conf && \
    echo "command=/usr/bin/falkon --no-remote --profile /root/.config/falkon/profile --no-session --start-maximized https://check.torproject.org" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=':0',QTWEBENGINE_CHROMIUM_FLAGS='--proxy-server=socks5://tor:9050 --disable-javascript'" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf

EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
