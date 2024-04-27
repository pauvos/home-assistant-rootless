FROM debian:12.5-slim

RUN apt update \
 && apt-get install -y python3 python3-dev python3-venv python3-pip bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev \
    autoconf build-essential libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata ffmpeg liblapack3 liblapack-dev libatlas-base-dev libpq-dev \
 && rm -rf /var/cache/apt /var/lib/apt/lists

RUN useradd -rm homeassistant \
 && mkdir /srv/homeassistant \
 && chown homeassistant:homeassistant /srv/homeassistant

EXPOSE 8123

CMD ["/srv/homeassistant/bin/hass", "--skip-pip"]

WORKDIR /srv/homeassistant

# renovate: datasource=github-releases depName=home-assistant/core
ARG HOME_ASSISTANT_VERSION=2024.3.3

ADD --chown=homeassistant:homeassistant \
    https://raw.githubusercontent.com/home-assistant/core/${HOME_ASSISTANT_VERSION}/requirements.txt \
    https://raw.githubusercontent.com/home-assistant/core/${HOME_ASSISTANT_VERSION}/requirements_all.txt \
    /srv/homeassistant/

USER homeassistant

RUN python3 -m venv . \
 && . bin/activate \
 && python3 -m pip install wheel \
 && python3 -m pip install psycopg2 \
 && pip3 install homeassistant==${HOME_ASSISTANT_VERSION} \
 && ln -s lib/python3.11/site-packages/homeassistant homeassistant \
 && pip3 install -r requirements_all.txt
