# Makefile

# Variables
DOCKER_IMAGE = openfga/openfga
DOCKER_CONTAINER_NAME = expenses-openfga
.PHONY := start stop clean

# Build and run the Docker container
start-openfga:
	docker run -d -p 3000:3000 -p 8080:8080 --name $(DOCKER_CONTAINER_NAME) $(DOCKER_IMAGE) run

# Stop and remove the Docker container
stop-openfga:
	docker stop $(DOCKER_CONTAINER_NAME)
	docker rm $(DOCKER_CONTAINER_NAME)

# Clean up the Docker images
clean:
	docker rmi $(DOCKER_IMAGE)