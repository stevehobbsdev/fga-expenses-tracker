# Makefile

# Variables
DOCKER_IMAGE = openfga/openfga
DOCKER_CONTAINER_NAME = expenses-openfga
STORE_NAME = "expenses-store"
ENV_FILE = .env
FGA_MODEL_FILE = ./config/expenses.fga
.PHONY := start-fga stop-fga lint setup_store

# Build and run the Docker container
start-fga:
	$ docker compose up -d

# Stop and remove the Docker container
stop-fga:
	$ docker compose down --remove-orphans

lint:
	$ rubocop -A

setup-store:
	@$(eval STORE_ID := $(shell fga store create --name "test" | jq '.store.id' --raw-output))
	@echo "Store ID: $(STORE_ID)"
	@$(shell sed -i '' 's/FGA_STORE_ID=.*$//FGA_STORE_ID=$(STORE_ID)/' $(ENV_FILE))
	@$(eval MODEL_ID := $(shell fga model write --store-id $(STORE_ID) --file $(FGA_MODEL_FILE) | jq '.authorization_model_id' --raw-output))
	@echo "Model ID: $(MODEL_ID)"
	@$(shell sed -i '' 's/FGA_MODEL_ID=.*$//FGA_MODEL_ID=$(MODEL_ID)/' $(ENV_FILE))
