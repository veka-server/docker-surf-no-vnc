FROM alpine:3.14

# Setup demo environment variables
ENV HOME=/root \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0.0 \
	DISPLAY_WIDTH=1280 \
	DISPLAY_HEIGHT=720

# Install git, supervisor, VNC, & X11 packages
RUN apk --update --upgrade add \
	bash \
	fluxbox \
	supervisor \
	x11vnc \
	xterm \
	xvfb
RUN mkdir /root/.vnc/ && x11vnc -storepasswd 1234 /root/.vnc/passwd

# Clone noVNC from github
ADD noVNC/ /root/noVNC/
COPY noVNC/vnc.html /root/noVNC/index.html

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
