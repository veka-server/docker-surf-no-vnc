FROM alpine:latest

# Installer les dépendances nécessaires
RUN apk add --no-cache \
    novnc \
    ttf-dejavu \
    fontconfig \
    xterm \
    supervisor \
#    python3 \
#    py3-pip \
#    git \
    fluxbox \
    tigervnc \
    websockify \
    firefox

# Créer les répertoires nécessaires
RUN mkdir -p /var/log/supervisor /root/.vnc
RUN mkdir -p /app/supervisor /app/.vnc /app/.config/openbox 


# --- CONFIGURATION FIREFOX PROFIL TEMPORAIRE ---
RUN mkdir -p /root/.mozilla/firefox/firefox-noscript && \
    echo 'user_pref("javascript.enabled", false);' > /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("extensions.enabledScopes", 0);' >> /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("extensions.autoDisableScopes", 15);' >> /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("network.proxy.type", 1);' >> /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("network.proxy.socks", "tor");' >> /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("network.proxy.socks_port", 9050);' >> /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("network.proxy.socks_version", 5);' >> /root/.mozilla/firefox/firefox-noscript/user.js && \
    echo 'user_pref("network.proxy.socks_remote_dns", true);' >> /root/.mozilla/firefox/firefox-noscript/user.js


# Copier les fichiers de configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Exposer les ports
EXPOSE 5900 6080

# Démarrer supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
