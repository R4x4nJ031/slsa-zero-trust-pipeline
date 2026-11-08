FROM node:22-trixie-slim

RUN apt-get update \
    && apt-get upgrade --yes \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY src/server.js ./server.js
USER node

EXPOSE 8080

CMD ["node", "server.js"]
