# =========================
# Dockerfile Alpine + Fluxbox + x11vnc + noVNC + xterm
# =========================
FROM alpine:latest

# =========================
# Install required packages
# =========================
RUN apk add --no-cache \
    fluxbox \
    xterm \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    ttf-dejavu \
    mesa-gl \
    dbus-x11 \
    bash \
    curl \
    tini

# =========================
# Set environment variables
# =========================
ENV DISPLAY=:0
ENV NO_VNC_HOME=/usr/share/novnc
ENV VNC_PORT=5900
ENV NOVNC_PORT=8080

# =========================
# Create VNC password
# =========================
RUN mkdir -p /root/.vnc && \
    x11vnc -storepasswd "password" /root/.vnc/passwd

# =========================
# Fluxbox startup script
# =========================
RUN echo '#!/bin/sh\n\
xterm &\n\
fluxbox &' > /root/start_fluxbox.sh && chmod +x /root/start_fluxbox.sh

# =========================
# Expose ports
# =========================
EXPOSE 5900 8080

# =========================
# Start everything
# =========================
CMD ["tini", "--", "sh", "-c", "\
  Xvfb :0 -screen 0 1024x768x16 & \
  sleep 1 && \
  /root/start_fluxbox.sh & \
  x11vnc -forever -usepw -display :0 -rfbport $VNC_PORT & \
  websockify --web $NO_VNC_HOME $NOVNC_PORT localhost:$VNC_PORT \
"]
