FROM alpine AS build

WORKDIR /app

COPY package*.json index.js ./

RUN apk add --no-cache nodejs npm curl && \
    npm install --production && \
    curl -sf https://gobinaries.com/tj/node-prune | sh && \
    node-prune

FROM alpine

WORKDIR /app

ARG PORT=3000
ARG USER=node

COPY --from=build /app/index.js /app/package.json ./
COPY --from=build /app/node_modules ./node_modules/

RUN apk add --no-cache nodejs npm && \
    adduser -D ${USER} && \
    chown -R ${USER}:${USER} /app

USER ${USER}

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:${PORT} || exit 1

CMD [ "npm", "run", "start" ]
