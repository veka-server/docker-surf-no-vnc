FROM alpine:latest

# Installer les dépendances nécessaires
RUN apk add --no-cache \
    xvfb \
    x11vnc \
    novnc \
    xterm \
    supervisor \
    python3 \
    py3-pip \
    git \
    fluxbox \
    tigervnc \
    websockify

# Créer les répertoires nécessaires
RUN mkdir -p /var/log/supervisor /root/.vnc
RUN mkdir -p /app/supervisor /app/.vnc /app/.config/openbox 

# Copier les fichiers de configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Exposer les ports
EXPOSE 5900 6080

# Démarrer supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
