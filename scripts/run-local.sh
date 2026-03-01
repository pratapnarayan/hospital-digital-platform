#!/usr/bin/env bash

set -euo pipefail

# Simple local runner for the MVP.
# Prereq: MongoDB must already be running on localhost:27017

echo "============================================="
echo "Hospital Digital Platform - local runner"
echo "Prerequisite: MongoDB running on localhost:27017"
echo "Starting Spring Boot services (gateway -> auth -> patient -> record -> notification)"
echo "============================================="

start_service() {
  local name="$1"
  local module="$2"
  local port="$3"

  echo "[run-local] Starting ${name} (${module}) on port ${port}..."
  mvn -q -f backend/pom.xml -pl "${module}" -am spring-boot:run &
  local pid=$!
  echo "[run-local] ${name} started with PID ${pid}"
  echo "[run-local] Sleeping 7s to allow ${name} to initialize..."
  sleep 7

  echo "${pid}"
}

GATEWAY_PID=$(start_service "Gateway Service" "gateway-service" "8080")
AUTH_PID=$(start_service "Auth Service" "auth-service" "8081")
PATIENT_PID=$(start_service "Patient Service" "patient-service" "8082")
RECORD_PID=$(start_service "Record Service" "record-service" "8083")
NOTIFICATION_PID=$(start_service "Notification Service" "notification-service" "8084")

echo "============================================="
echo "All services started. PIDs:"
echo "- Gateway:       ${GATEWAY_PID}"
echo "- Auth:          ${AUTH_PID}"
echo "- Patient:       ${PATIENT_PID}"
echo "- Record:        ${RECORD_PID}"
echo "- Notification:  ${NOTIFICATION_PID}"
echo ""
echo "Gateway health check: http://localhost:8080/health"
echo "Record health check (via gateway): http://localhost:8080/record/health"
echo "============================================="

echo "[run-local] Streaming will continue until you stop this script (Ctrl+C)."
wait
