FROM python:3.11-slim AS builder

WORKDIR /app

ARG DOPPLER_TOKEN  # Optional, for future use if needed
ENV DOPPLER_TOKEN=${DOPPLER_TOKEN}

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  wget \
  software-properties-common \
  git \
  imagemagick \
  && rm -rf /var/lib/apt/lists/*

RUN cat /etc/ImageMagick-6/policy.xml | sed 's/none/read,write/g'> /etc/ImageMagick-6/policy.xml

COPY . .

RUN pip install poetry

RUN poetry config virtualenvs.create false

RUN poetry install
RUN pip install "git+https://github.com/Zulko/moviepy.git"

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT [ "python", "-m", "streamlit", "run", "reelsmaker.py", "--server.port=8501", "--server.address=0.0.0.0" ]
