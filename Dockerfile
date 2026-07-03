FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Core Desktop + Browsers + Audio Support
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal xfce4-screenshooter \
    xrdp xorgxrdp dbus-x11 x11-xserver-utils \
    firefox-esr chromium \
    sudo wget curl procps net-tools \
    && apt-get clean

# 2. Optimization: Tweak XRDP for High-Speed Network & RemoteFX
RUN sed -i 's/tcp_send_buffer_bytes=32768/tcp_send_buffer_bytes=4194304/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/tcp_recv_buffer_bytes=32768/tcp_recv_buffer_bytes=4194304/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/use_compression=yes/use_compression=no/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/crypt_level=high/crypt_level=low/g' /etc/xrdp/xrdp.ini

# 3. Optimization: Force Xorg as the primary backend
RUN sed -i 's/Priority=1/Priority=0/g' /etc/xrdp/sesman.ini

# 4. Browser Fix: Chromium needs --no-sandbox to run in Railway
RUN ln -s /usr/bin/chromium /usr/local/bin/browser && \
    echo '#!/bin/bash\n/usr/bin/chromium --no-sandbox --disable-dev-shm-usage "$@"' > /usr/local/bin/chrome && \
    chmod +x /usr/local/bin/chrome

# 5. Set default desktop to XFCE
RUN echo "startxfce4" > /etc/skel/.xsession

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]
