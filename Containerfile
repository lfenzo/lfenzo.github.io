FROM debian:unstable

RUN apt update && apt install hugo -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

EXPOSE 1313

CMD ["hugo"]
