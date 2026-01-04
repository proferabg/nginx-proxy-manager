# This is a Dockerfile intended to be built using `docker buildx`
# for multi-arch support. Building with `docker build` may have unexpected results.

# This file assumes that the frontend has been built using ./scripts/frontend-build

FROM nginxproxymanager/testca AS testca
FROM nginxproxymanager/nginx-full:certbot-node

ARG TARGETPLATFORM
ARG BUILD_VERSION
ARG BUILD_COMMIT
ARG BUILD_DATE

# See: https://github.com/just-containers/s6-overlay/blob/master/README.md
ENV SUPPRESS_NO_CONFIG_WARNING=1 \
	S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
	S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
	S6_FIX_ATTRS_HIDDEN=1 \
	S6_KILL_FINISH_MAXTIME=10000 \
	S6_VERBOSITY=1 \
	NODE_ENV=production \
	NPM_BUILD_VERSION="${BUILD_VERSION}" \
	NPM_BUILD_COMMIT="${BUILD_COMMIT}" \
	NPM_BUILD_DATE="${BUILD_DATE}" \
	NODE_OPTIONS="--openssl-legacy-provider"

RUN echo "fs.file-max = 65535" > /etc/sysctl.conf \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends jq logrotate supervisor \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY supervisor /supervisor

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh" ]
ENTRYPOINT ["/bin/bash"]

LABEL org.label-schema.schema-version="1.0" \
	org.label-schema.license="MIT" \
	org.label-schema.name="nginx-proxy-manager-ptero" \
	org.label-schema.description="Docker container for managing Nginx proxy hosts with a simple, powerful interface, pterodactyl compatible" \
	org.label-schema.url="https://github.com/proferabg/nginx-proxy-manager" \
	org.label-schema.vcs-url="https://github.com/proferabg/nginx-proxy-manager.git" \
	org.label-schema.cmd="docker run --rm -ti proferabg/npm-ptero:latest"



