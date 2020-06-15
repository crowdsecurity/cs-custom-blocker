<p align="center">
<img src="https://github.com/crowdsecurity/cs-custom-blocker/raw/master/docs/assets/crowdsec_linux_logo.png" alt="CrowdSec" title="CrowdSec" width="280" height="400" />
</p>
<p align="center">
<img src="https://img.shields.io/badge/build-pass-green">
<img src="https://img.shields.io/badge/tests-pass-green">
</p>

# CrowdSec Custom Blocker

cs-custom-blocker is a systemd-service that monitors whenever a an is added/removed/expired in SQLite database.

When such change happen, a user-supplied script is called (see `/etc/crowdsec/custom-blocker/custom-blocker.yaml`), with the following arguments :

> when a ban is added

 - `add <IP> <SECONDS_TO_BAN> <REASON> <JSON_OBJECT>`

> when a ban is manually removed or expires

 - `del <IP> <SECONDS_TO_BAN> <REASON> <JSON_OBJECT>}`

The 'JSON_OBJECT' is a serialized object representing the ban decision and looks like :

```json
{
  "MeasureSource": "cli",
  "MeasureType": "ban",
  "MeasureExtra": "",
  "Until": "2020-06-15T12:26:47.023217323+02:00",
  "StartIp": 16909060, #ip as integer range
  "EndIp": 16909060, #ip as integer range
  "TargetCN": "", #source country
  "TargetAS": 0, #source as number
  "TargetASName": "", #source as name
  "IpText": "1.2.3.4", #ip in textual representation
  "Reason": "because", #scenario/reason
  "Scenario": "", #scenario
  "SignalOccurenceID": 1
}

```

## Installation

Download the [latest release](https://github.com/crowdsecurity/cs-custom-blocker/releases).

```bash
tar xzvf cs-custom-blocker.tgz
cd cs-custom-blocker...
sudo ./install.sh
systemctl status custom-blocker
tail -f /var/log/custom-blocker.log
```


# Troubleshooting

 - Logs are in `/var/log/custom-blocker.log`
 - You can view/interact directly in the ban list with `cwcli`
 - Service can be started/stopped with `systemctl start/stop custom-blocker`

