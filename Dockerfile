ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS dependencies

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  wget \
  software-properties-common \
  git \
  imagemagick \
  libmagickwand-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install poetry

FROM dependencies AS builder

RUN cat /etc/ImageMagick-6/policy.xml | sed 's/none/read,write/g'> /etc/ImageMagick-6/policy.xml

WORKDIR /app

COPY poetry.lock poetry.lock
COPY pyproject.toml pyproject.toml

RUN poetry config virtualenvs.create false
RUN poetry install --no-root

RUN apt-get -y update #&& apt-get -y upgrade && 
RUN apt-get install -y --no-install-recommends ffmpeg


COPY . .

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT [ "python", "-m", "streamlit", "run", "reelsmaker.py", "--server.port=8501", "--server.address=0.0.0.0" ]
