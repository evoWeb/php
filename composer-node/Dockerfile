# Set component images
FROM composer:2 AS composer

# Create base image
FROM php:8-cli-alpine3.21

# Copy artifacts from component images
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install dependencies
RUN apk add \
	--update \
	--no-cache \
	# Deployment
	bash \
	git \
	rsync \
	# Front-end tools
	nodejs \
	npm

ENTRYPOINT ["/bin/sh", "-c"]
