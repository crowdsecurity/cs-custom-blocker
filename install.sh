#!/usr/bin/env bash
BIN_PATH_INSTALLED="/usr/local/bin/cs-custom-blocker"
BIN_PATH="./cs-custom-blocker"
CONFIG_DIR="/etc/crowdsec/cs-custom-blocker/"
PID_DIR="/var/run/crowdsec/"
SYSTEMD_PATH_FILE="/etc/systemd/system/cs-custom-blocker.service"

install_custom_blocker() {
	install -v -m 755 -D "${BIN_PATH}" "${BIN_PATH_INSTALLED}"
	mkdir -p "${CONFIG_DIR}"
	cp "./config/cs-custom-blocker.yaml" "${CONFIG_DIR}/cs-custom-blocker.yaml"
	CFG=${CONFIG_DIR} PID=${PID_DIR} BIN=${BIN_PATH_INSTALLED} envsubst < ./config/cs-custom-blocker.service > "${SYSTEMD_PATH_FILE}"
	systemctl daemon-reload
	#systemctl startcs-custom-blocker
}


echo "Installing cs-custom-blocker"
install_custom_blocker
