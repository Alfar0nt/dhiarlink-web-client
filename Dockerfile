FROM node:26.3-alpine AS node
ARG VERSION="latest"
ENV VERSION=${VERSION}

# Install dependencies first (cached unless package files change)
COPY package.json package-lock.json /dhiarlink-web-client/
WORKDIR /dhiarlink-web-client
RUN npm ci

# Copy source and build
COPY . .
RUN node --run build

FROM nginxinc/nginx-unprivileged:1.31.1-alpine
ARG UID=101
LABEL maintainer="Dhiarlink <dhiarlink@dhiarr.qzz.io>"

USER root
RUN rm -r /usr/share/nginx/html && rm /etc/nginx/conf.d/default.conf
COPY config/docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY scripts/docker/servers_from_env.sh /docker-entrypoint.d/30-dhiarlink-servers-json.sh
COPY --from=node /dhiarlink-web-client/build /usr/share/nginx/html

# This is required by 30-dhiarlink-servers-json.sh to be writable for UID
RUN echo '[]' > /usr/share/nginx/html/servers.json \
    && chown $UID:0 /usr/share/nginx/html/servers.json

# Switch to non-privileged UID as the last step
USER $UID
