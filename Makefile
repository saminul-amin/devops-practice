# Makefile for MERN E-commerce DevOps Hackathon

# Variables
DOCKER_COMPOSE_DEV = docker/compose.development.yaml
DOCKER_COMPOSE_PROD = docker/compose.production.yaml
DOCKER_COMPOSE_HUB = docker/compose.hub.yaml
ENV_FILE = .env
DOCKER_REPO = uday2027/s2e1-hack-cuet-2025

# Colors
GREEN = \033[0;32m
NC = \033[0m

.PHONY: help build-dev up-dev down-dev build-prod up-prod down-prod clean logs

help:
	@echo "Available commands:"
	@echo "  ${GREEN}Quick Start:${NC}"
	@echo "  make dev         - Setup + Build + Start development (ONE COMMAND)"
	@echo "  make prod        - Setup + Build + Start production (ONE COMMAND)"
	@echo "  make hub         - Setup + Pull + Start using Docker Hub images"
	@echo ""
	@echo "  ${GREEN}Step-by-Step:${NC}"
	@echo "  make setup       - Setup environment variables"
	@echo "  make build-dev   - Build development images"
	@echo "  make up-dev      - Start development environment"
	@echo "  make down-dev    - Stop development environment"
	@echo "  make build-prod  - Build production images"
	@echo "  make up-prod     - Start production environment"
	@echo "  make down-prod   - Stop production environment"
	@echo "  make clean       - Remove containers, networks, and volumes"
	@echo "  make logs        - View logs"
	@echo "  make test        - Run automated tests"
	@echo ""
	@echo "  ${GREEN}Docker Hub:${NC}"
	@echo "  make push        - Build and push images to Docker Hub"
	@echo "  make pull        - Pull images from Docker Hub"

# Quick Start Commands
dev: setup build-dev up-dev
	@echo "${GREEN}Development environment is ready!${NC}"
	@echo "Gateway: http://localhost:5921"
	@echo "Run 'make test' to verify everything works"

prod: setup build-prod up-prod
	@echo "${GREEN}Production environment is ready!${NC}"
	@echo "Gateway: http://localhost:5921"
	@echo "Run 'make test' to verify everything works"

# Setup
setup:
	@echo "${GREEN}Setting up environment...${NC}"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "${GREEN}Created .env file from .env.example${NC}"; \
	else \
		echo "${GREEN}.env file already exists, skipping...${NC}"; \
	fi


# Development Commands
build-dev:
	@echo "${GREEN}Building development images...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_DEV) build

up-dev:
	@echo "${GREEN}Starting development environment...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_DEV) up -d

down-dev:
	@echo "${GREEN}Stopping development environment...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_DEV) down

# Production Commands
build-prod:
	@echo "${GREEN}Building production images...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_PROD) build

up-prod:
	@echo "${GREEN}Starting production environment...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_PROD) up -d

down-prod:
	@echo "${GREEN}Stopping production environment...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_PROD) down

# Utility Commands
clean:
	@echo "${GREEN}Cleaning up...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_DEV) down -v --rmi local
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_PROD) down -v --rmi local

logs:
	@echo "${GREEN}Showing logs...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_DEV) logs -f

test:
	@echo "${GREEN}Running tests...${NC}"
	@echo "Checking Gateway Health..."
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:5921/health | grep 200 > /dev/null && echo "${GREEN}Gateway Health: OK${NC}" || echo "Gateway Health: FAILED"
	@echo "Checking Backend Health..."
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:5921/api/health | grep 200 > /dev/null && echo "${GREEN}Backend Health: OK${NC}" || echo "Backend Health: FAILED"
	@echo "Creating Product..."
	@curl -s -X POST http://localhost:5921/api/products -H 'Content-Type: application/json' -d '{"name":"Test Product","price":99.99}' > /dev/null && echo "${GREEN}Create Product: OK${NC}" || echo "Create Product: FAILED"
	@echo "Listing Products..."
	@curl -s http://localhost:5921/api/products > /dev/null && echo "${GREEN}List Products: OK${NC}" || echo "List Products: FAILED"

# Docker Hub Commands
push: build-prod
	@echo "${GREEN}Pushing images to Docker Hub...${NC}"
	docker tag docker-backend:latest $(DOCKER_REPO):backend
	docker tag docker-gateway:latest $(DOCKER_REPO):gateway
	docker push $(DOCKER_REPO):backend
	docker push $(DOCKER_REPO):gateway
	@echo "${GREEN}Images pushed successfully!${NC}"

pull:
	@echo "${GREEN}Pulling images from Docker Hub...${NC}"
	docker pull $(DOCKER_REPO):backend
	docker pull $(DOCKER_REPO):gateway
	@echo "${GREEN}Images pulled successfully!${NC}"

hub: setup pull
	@echo "${GREEN}Starting environment with Docker Hub images...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_HUB) up -d
	@echo "${GREEN}Environment ready using Docker Hub images!${NC}"
	@echo "Gateway: http://localhost:5921"
	@echo "Run 'make test' to verify everything works"

down-hub:
	@echo "${GREEN}Stopping Docker Hub environment...${NC}"
	docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_HUB) down

