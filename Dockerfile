FROM node:10.15-stretch-slim

LABEL maintainer "Alpeware <info@alpeware.com>"

ENV REV=634997

EXPOSE 9222

RUN apt-get update -qqy \
  && apt-get -qqy install libnss3 libnss3-tools libfontconfig1 wget ca-certificates apt-transport-https inotify-tools unzip \
  libpangocairo-1.0-0 libx11-xcb-dev libxcomposite-dev libxcursor1 libxdamage1 libxi6 libgconf-2-4 libxtst6 libcups2-dev \
  libxss-dev libxrandr-dev libasound2-dev libatk1.0-dev libgtk-3-dev ttf-ancient-fonts libappindicator3-1 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
	&& dpkg -i dumb-init_*.deb \
	&& rm dumb-init_1.2.0_amd64.deb

RUN wget -q -O chrome.zip https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/$REV/chrome-linux.zip \
  && unzip chrome.zip \
  && rm chrome.zip \
  && ln -s $PWD/chrome-linux/chrome /usr/bin/google-chrome-unstable

RUN cd home && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg-extra_71.0.3578.98-0ubuntu0.16.04.1_amd64.deb && \
    dpkg -i chromium-codecs-ffmpeg-extra_71.0.3578.98-0ubuntu0.16.04.1_amd64.deb && \
    apt-get install -f

RUN google-chrome-unstable --version

ADD start.sh import_cert.sh /usr/bin/

RUN mkdir /data
VOLUME /data
ENV HOME=/data DEBUG_ADDRESS=0.0.0.0 DEBUG_PORT=9222

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/usr/bin/start.sh"]
