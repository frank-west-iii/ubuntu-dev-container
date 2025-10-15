#!/usr/bin/env bash

# Helper script to manage branch-specific development containers

set -e

# Get current git branch
get_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"
}

# Sanitize branch name for use in volume names (replace special chars with dashes)
sanitize_branch() {
    echo "$1" | sed 's/[^a-zA-Z0-9_-]/-/g'
}

BRANCH_NAME=$(sanitize_branch "$(get_branch)")
export COMPOSE_PROJECT_NAME="ubuntu-dev-${BRANCH_NAME}"

# Display current configuration
echo "Branch: $(get_branch)"
echo "Project: ${COMPOSE_PROJECT_NAME}"
echo "Volume: ${COMPOSE_PROJECT_NAME}_dev-home"
echo "Container: ${COMPOSE_PROJECT_NAME}"
echo ""

# Run docker-compose with the provided arguments
docker-compose "$@"
