FROM alpine:latest

# =========================
# Dépendances système + Firefox
# =========================
RUN set -xe \
    && addgroup pulse \
    && apk add --no-cache --purge -uU \
        adwaita-icon-theme \
        alsa-plugins-pulse \
        alsa-utils \
        curl \
        ca-certificates \
        dbus-x11 \
        ffmpeg-libs \
        icu-libs \
        iso-codes \
        libcanberra-gtk3 \
        libexif \
        libpciaccess \
        linux-firmware-i915 \
        mesa-dri-gallium \
        mesa-egl \
        mesa-gl \
        mesa-va-gallium \
        mesa-vulkan-swrast \
        pango \
        pciutils-libs \
        pulseaudio \
        ttf-dejavu \
        ttf-freefont \
        udev \
        unzip \
        zlib-dev \
        xvfb \
        fluxbox \
        x11vnc \
        supervisor \
        novnc \
        websockify \
        bash \
        tini \
        firefox \
        firefox-intl \
        geckodriver

# =========================
# Création profil Firefox
# =========================
RUN mkdir -p /root/.mozilla/firefox/profile

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
    echo "command=/usr/bin/firefox --no-remote --profile /root/.mozilla/firefox/profile --new-instance https://check.torproject.org" >> /etc/supervisord.conf && \
    echo "environment=DISPLAY=':0',MOZ_DISABLE_CONTENT_SANDBOX=1,ALL_PROXY='socks5://tor:9050'" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf

# =========================
# Ports et démarrage
# =========================
EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
