FROM python:3.9-slim

LABEL maintainer="Jeromeliaya <20josemespitia@gmail.com>"
LABEL repository="https://github.com/good-girls/Melody"

RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && rm -rf /var/lib/apt/lists/*

RUN if ! command -v curl >/dev/null 2>&1; then \
    apt-get update && apt-get install -y curl; \
fi

ENV Melody_SERVER_PORT=1109
ENV GIN_MODE=release
ENV TELEGRAM_BOT_TOKEN=your_bot_token_here

WORKDIR /Melody

COPY . /Melody

RUN curl -O https://raw.githubusercontent.com/good-girls/Melody/main/Melody.py \
    pip install --no-cache-dir python-telegram-bot --upgrade \
    && pip install --no-cache-dir "python-telegram-bot[job-queue]"

EXPOSE 1109

CMD ["python", "Melody.py"]
