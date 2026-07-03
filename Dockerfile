FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Core Desktop + Browsers + Performance Tools
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal xfce4-screenshooter \
    xrdp xorgxrdp dbus-x11 x11-xserver-utils \
    firefox-esr chromium \
    sudo wget curl procps net-tools \
    && apt-get clean

# 2. Optimization: Tweak XRDP for High-Speed Network
RUN sed -i 's/tcp_send_buffer_bytes=32768/tcp_send_buffer_bytes=4194304/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/tcp_recv_buffer_bytes=32768/tcp_recv_buffer_bytes=4194304/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/crypt_level=high/crypt_level=low/g' /etc/xrdp/xrdp.ini

# 3. CRITICAL: Allow Root Login
# This removes the security block that prevents root from using RDP
RUN sed -i 's/AllowRootLogin=false/AllowRootLogin=true/g' /etc/xrdp/sesman.ini

# 4. Browser Fix: Chromium needs --no-sandbox
RUN echo '#!/bin/bash\n/usr/bin/chromium --no-sandbox --disable-dev-shm-usage "$@"' > /usr/local/bin/chrome && \
    chmod +x /usr/local/bin/chrome

# 5. Set default desktop to XFCE
RUN echo "startxfce4" > /root/.xsession

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]
