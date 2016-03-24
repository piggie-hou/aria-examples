#!/bin/bash

set -x

ctx logger info "Installing Dependencies"
sudo apt-get update -y
sudo apt-get install gcc make build-essential -y
