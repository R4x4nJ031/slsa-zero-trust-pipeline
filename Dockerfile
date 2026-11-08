FROM gcr.io/distroless/nodejs22-debian12:nonroot

WORKDIR /app
COPY src/server.js ./server.js

EXPOSE 8080

CMD ["server.js"]
