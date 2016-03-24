#!/bin/bash

set -x

PID=$(ctx instance runtime_properties pid)

kill -9 ${PID}

ctx logger info "Successfully stopped MongoDB (${PID})"
