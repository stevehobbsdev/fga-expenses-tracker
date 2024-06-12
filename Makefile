# Makefile

# Variables
DOCKER_IMAGE = openfga/openfga
DOCKER_CONTAINER_NAME = expenses-openfga
.PHONY := start-fga stop-fga lint

# Build and run the Docker container
start-fga:
	$ docker compose up

# Stop and remove the Docker container
stop-fga:
	$ docker compose down

lint:
	$ rubocop -A
