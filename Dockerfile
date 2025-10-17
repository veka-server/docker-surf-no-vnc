FROM alpine:latest

# Installer les dépendances nécessaires
RUN apk add --no-cache \
    xvfb \
    x11vnc \
    xterm \
    supervisor \
    python3 \
    py3-pip \
    git \
    fluxbox \
    novnc \
    websockify

# Créer les répertoires nécessaires
RUN mkdir -p /var/log/supervisor /root/.vnc

# Copier les fichiers de configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY vnc.sh /usr/local/bin/vnc.sh
RUN chmod +x /usr/local/bin/vnc.sh

# Exposer les ports
EXPOSE 5900 6080

# Démarrer supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
