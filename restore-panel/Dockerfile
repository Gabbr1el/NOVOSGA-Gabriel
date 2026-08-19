FROM node:22-bookworm-slim AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund && npm cache clean --force

FROM node:22-bookworm-slim AS runtime
ENV NODE_ENV=production PORT=8080
RUN apt-get update \
    && apt-get install -y --no-install-recommends default-mysql-client ca-certificates tini \
    && rm -rf /var/lib/apt/lists/* \
    && if ! command -v mysqlbinlog >/dev/null 2>&1 && command -v mariadb-binlog >/dev/null 2>&1; then ln -s /usr/bin/mariadb-binlog /usr/local/bin/mysqlbinlog; fi \
    && command -v mysql >/dev/null \
    && command -v mysqlbinlog >/dev/null
WORKDIR /app
COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node package.json ./
COPY --chown=node:node src ./src
COPY --chown=node:node public ./public
USER node
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "src/server.js"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["node", "-e", "fetch('http://127.0.0.1:8080/health').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"]
