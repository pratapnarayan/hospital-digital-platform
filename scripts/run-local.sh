#!/usr/bin/env bash

set -euo pipefail

# Simple local runner for the MVP.
# Prereq: MongoDB must already be running on localhost:27017

echo "============================================="
echo "Hospital Digital Platform - local runner"
echo "Prerequisite: MongoDB running on localhost:27017"
echo "Starting Spring Boot services (gateway -> auth -> patient -> record -> notification)"
echo "============================================="

# Resolve repo root so the script works from any current directory.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
# Module POM locations (avoid running spring-boot:run on the parent 'backend' POM)
BACKEND_DIR="${REPO_ROOT}/backend"

# Ensure shared library is in the local Maven repo before starting services.
# (Auth/Record depend on it.)
echo "[run-local] Installing common-libs (skip tests)..."
echo "[run-local] NOTE: First run may take a few minutes while Maven downloads dependencies."
(
  mvn -f "${BACKEND_DIR}/common-libs/pom.xml" install -DskipTests
)

echo "============================================="

start_service() {
  local name="$1"
  local module="$2"
  local port="$3"

  local log_dir="${REPO_ROOT}/.run-local-logs"
  mkdir -p "${log_dir}"
  local log_file="${log_dir}/${module}.log"

  echo "[run-local] Starting ${name} (${module}) on port ${port}..."
  echo "[run-local] Logging ${module} output to: ${log_file}"

  (
    mvn -f "${BACKEND_DIR}/${module}/pom.xml" spring-boot:run -DskipTests
  ) >"${log_file}" 2>&1 &

  local pid=$!
  echo "[run-local] ${name} started with PID ${pid}"

  # Wait until the port is reachable, or the process exits.
  local max_wait_seconds=60
  local waited=0
  while true; do
    if ! kill -0 "${pid}" 2>/dev/null; then
      echo "[run-local] ERROR: ${name} (PID ${pid}) exited during startup."
      echo "[run-local] Last 200 lines from ${log_file}:"
      tail -n 200 "${log_file}" || true
      return 1
    fi

    if command -v curl >/dev/null 2>&1; then
      if curl -fsS "http://localhost:${port}/actuator/health" >/dev/null 2>&1 || \
         curl -fsS "http://localhost:${port}/health" >/dev/null 2>&1; then
        break
      fi
    fi

    if [ "${waited}" -ge "${max_wait_seconds}" ]; then
      echo "[run-local] WARN: ${name} did not become healthy within ${max_wait_seconds}s."
      echo "[run-local] You can inspect logs at ${log_file}."
      break
    fi

    sleep 2
    waited=$((waited + 2))
  done

  echo "${pid}"
}

GATEWAY_PID=$(start_service "Gateway Service" "gateway-service" "8080")
AUTH_PID=$(start_service "Auth Service" "auth-service" "8081")
PATIENT_PID=$(start_service "Patient Service" "patient-service" "8082")
RECORD_PID=$(start_service "Record Service" "record-service" "8083")
NOTIFICATION_PID=$(start_service "Notification Service" "notification-service" "8084")

LOG_DIR="${REPO_ROOT}/.run-local-logs"

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
echo "Service logs directory: ${LOG_DIR}"
echo "============================================="

echo "[run-local] Streaming will continue until you stop this script (Ctrl+C)."
wait
