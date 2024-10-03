FROM python:3.12-bookworm

RUN apt update \
 && apt-get install -y \
    build-essential \
    libpq-dev \
    ffmpeg \
 && rm -rf /var/cache/apt /var/lib/apt/lists

RUN useradd -rm homeassistant \
 && mkdir /srv/homeassistant \
 && chown homeassistant:homeassistant /srv/homeassistant

EXPOSE 8123

CMD ["/srv/homeassistant/bin/hass", "--skip-pip"]

WORKDIR /srv/homeassistant

# renovate: datasource=github-releases depName=home-assistant/core
ARG HOME_ASSISTANT_VERSION=2024.10.0

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
 && ln -s lib/python3.12/site-packages/homeassistant homeassistant \
 && pip3 install -r requirements_all.txt
