#!/bin/bash

set -x

ctx source instance runtime-properties nodejs_binaries_path $(ctx target instance runtime_properties nodejs_binaries_path)
