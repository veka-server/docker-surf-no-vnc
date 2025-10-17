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

# Configurer VNC
RUN echo "#!/bin/sh" > /usr/local/bin/vnc.sh && \
    echo "Xvfb :99 -screen 0 1280x720x24 &" >> /usr/local/bin/vnc.sh && \
    echo "sleep 2" >> /usr/local/bin/vnc.sh && \
    echo "DISPLAY=:99 fluxbox &" >> /usr/local/bin/vnc.sh && \
    echo "x11vnc -display :99 -forever -nopw" >> /usr/local/bin/vnc.sh && \
    chmod +x /usr/local/bin/vnc.sh

# Configurer Supervisor
RUN echo "[supervisord]" > /etc/supervisor/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[program:vnc]" >> /etc/supervisor/supervisord.conf && \
    echo "command=/usr/local/bin/vnc.sh" >> /etc/supervisor/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/vnc.log" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[program:novnc]" >> /etc/supervisor/supervisord.conf && \
    echo "command=websockify 6080 localhost:5900" >> /etc/supervisor/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/novnc.log" >> /etc/supervisor/supervisord.conf

# Exposer les ports
EXPOSE 5900 6080

# Démarrer supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
