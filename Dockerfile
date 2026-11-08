FROM node:22-alpine

WORKDIR /app
COPY src/server.js ./server.js

RUN addgroup -S app && adduser -S app -G app
USER app

ENV NODE_ENV=production
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s CMD wget --spider -q http://127.0.0.1:8080/healthz || exit 1

CMD ["node", "server.js"]