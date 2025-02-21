#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Run RSpec tests inside the Docker container
LINE_SERVER_FILE="./sample.txt" docker compose run --rm line-server bundle exec rspec