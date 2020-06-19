#!/bin/bash

BIN_PATH_INSTALLED="/usr/local/bin/cs-custom-blocker"
CONFIG_DIR="/etc/crowdsec/cs-custom-blocker/"
PID_DIR="/var/run/crowdsec/"
SYSTEMD_PATH_FILE="/etc/systemd/system/cs-custom-blocker.service"

uninstall() {
	systemctl stop cs-custom-blocker
	rm -rf "${CONFIG_DIR}"
	rm -f "${SYSTEMD_PATH_FILE}"
	rm -f "${PID_DIR}/cs-custom-blocker.pid"
	rm -f "${BIN_PATH_INSTALLED}"
}

uninstall
