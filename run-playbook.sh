#!/bin/bash
set -euo pipefail

REQS_FILE="./roles/requirements.yml"
INVENTORY_FILE="variables/cli/hosts.ini"
EXTRA_VARS_DIR="variables/cli"
ANSIBLE_GALAXY="/usr/bin/ansible-galaxy"
ANSIBLE_PLAYBOOK="/usr/bin/ansible-playbook"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <playbook.yml> [requirements.yml] [inventory.ini] [extra_vars.json]"
  exit 1
fi

PLAYBOOK_FILE="$1"

if [[ $# -ge 2 ]]; then
  REQS_FILE="$2"
fi

if [[ $# -ge 3 ]]; then
  INVENTORY_FILE="$3"
fi

if [[ $# -ge 4 ]]; then
  EXTRA_VARS_FILE="$4"
else
  PLAYBOOK_NAME="$(basename "${PLAYBOOK_FILE}" .yml)"
  EXTRA_VARS_FILE="${EXTRA_VARS_DIR}/${PLAYBOOK_NAME}-extravars.json"
fi

if [[ -f "${REQS_FILE}" ]]; then
  echo "Installing roles from: ${REQS_FILE}"
  ${ANSIBLE_GALAXY} role install -r "${REQS_FILE}" --roles-path roles/
else
  echo "No requirements file found at ${REQS_FILE}, skipping role installation."
fi

CMD=("${ANSIBLE_PLAYBOOK}" "${PLAYBOOK_FILE}" -i "${INVENTORY_FILE}")

if [[ -f "${EXTRA_VARS_FILE}" ]]; then
  echo "Using extra vars: ${EXTRA_VARS_FILE}"
  CMD+=(-e "@${EXTRA_VARS_FILE}")
else
  echo "No extra vars found at ${EXTRA_VARS_FILE}, continuing without."
fi

echo "Running: ${CMD[*]}"
"${CMD[@]}"
