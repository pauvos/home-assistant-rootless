FROM python:3.13-bookworm@sha256:3856e3e7bf4d0ba061501a84ed2eb0d429663307c0f54f191dc4de03c7081c3e

RUN apt update \
 && apt-get install -y \
    build-essential \
    libpq-dev \
    ffmpeg \
 && rm -rf /var/cache/apt /var/lib/apt/lists

RUN useradd -rm homeassistant \
 && mkdir -p /srv/homeassistant/homeassistant \
 && chown homeassistant:homeassistant -R /srv/homeassistant

EXPOSE 8123

CMD ["/srv/homeassistant/bin/hass", "--skip-pip"]

WORKDIR /srv/homeassistant

ENV UV_SYSTEM_PYTHON=true \
    UV_NO_CACHE=true \
    UV_HTTP_TIMEOUT=60s

# renovate: datasource=github-releases depName=home-assistant/core
ARG HOME_ASSISTANT_VERSION=2025.9.4

ADD --chown=homeassistant:homeassistant \
    https://raw.githubusercontent.com/home-assistant/core/${HOME_ASSISTANT_VERSION}/requirements.txt \
    https://raw.githubusercontent.com/home-assistant/core/${HOME_ASSISTANT_VERSION}/requirements_all.txt \
    /srv/homeassistant/

ADD --chown=homeassistant:homeassistant \
    https://raw.githubusercontent.com/home-assistant/core/${HOME_ASSISTANT_VERSION}/homeassistant/package_constraints.txt \
    /srv/homeassistant/homeassistant/

# Install uv
RUN pip3 --disable-pip-version-check --no-cache-dir install --root-user-action=ignore uv \
 && uv pip install psycopg2 homeassistant==${HOME_ASSISTANT_VERSION} \
 && uv pip install -r requirements_all.txt

USER homeassistant
