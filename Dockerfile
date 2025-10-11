FROM alpine:latest

# =========================
# Install minimal GUI + VNC + noVNC
# =========================
RUN apk add --no-cache \
    x11vnc \
    xvfb \
    fluxbox \
    xterm \
    bash \
    novnc \
    websockify \
    tini \
    ttf-dejavu \
    fontconfig \
    mesa-gl \
    dbus-x11

# =========================
# Environment variables
# =========================
ENV DISPLAY=:1
ENV NOVNC_PORT=8080
EXPOSE 5900 $NOVNC_PORT

# =========================
# Startup command
# =========================
CMD ["/sbin/tini", "--", "sh", "-c", "\
    # Start X virtual framebuffer \
    Xvfb $DISPLAY -screen 0 1024x768x16 & \
    sleep 2; \
    # Start window manager \
    fluxbox & \
    # Start a terminal \
    xterm & \
    # Start x11vnc, create display if needed \
    x11vnc -display $DISPLAY -forever -nopw -create & \
    # Start noVNC web server \
    websockify $NOVNC_PORT localhost:5900"
]
