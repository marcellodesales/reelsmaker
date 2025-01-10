FROM python:3.11-slim AS builder

WORKDIR /app



RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    software-properties-common \
    git \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    apt-get update && \
    

RUN cat /etc/ImageMagick-6/policy.xml | sed 's/none/read,write/g'> /etc/ImageMagick-6/policy.xml

COPY . .

RUN pip install poetry

RUN poetry config virtualenvs.create false

RUN poetry install --no-root
RUN pip install "git+https://github.com/Zulko/moviepy.git"

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

CMD ["python", "-m", "streamlit", "run", "reelsmaker.py", "--server.port=8501", "--server.address=0.0.0.0"]
