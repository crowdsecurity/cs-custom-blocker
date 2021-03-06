<p align="center">
<img src="https://github.com/crowdsecurity/cs-custom-blocker/raw/master/docs/assets/crowdsec_custom.png" alt="CrowdSec" title="CrowdSec" width="280" height="300" />
</p>
<p align="center">
<img src="https://img.shields.io/badge/build-pass-green">
<img src="https://img.shields.io/badge/tests-pass-green">
</p>
<p align="center">
&#x1F4DA; <a href="https://docs.crowdsec.net/blockers/netfilter/installation/">Documentation</a>
&#x1F4A0; <a href="https://hub.crowdsec.net">Hub</a>
&#128172; <a href="https://discourse.crowdsec.net">Discourse </a>
</p>

# CrowdSec Custom Blocker

A generic blocker that can invoke a custom crafted script when an IPs is banned or unbanned.

# How does it work ?

cs-custom-blocker is daemon that will monitor bans from SQLite/MySQL and invoke a user provided script every time an IP is banned or unbanned.

When such change happen, a user-supplied script is called (see `/etc/crowdsec/cs-custom-blocker/cs-custom-blocker.yaml`), with the following arguments :

> when a ban is added

 - `add <IP> <SECONDS_TO_BAN> <REASON> <JSON_OBJECT>`

> when a ban is manually removed or expires

 - `del <IP> <SECONDS_TO_BAN> <REASON> <JSON_OBJECT>`

# Installation


## Install script

Download the [latest release](https://github.com/crowdsecurity/cs-custom-blocker/releases).

```bash
tar xzvf cs-custom-blocker.tgz
cd cs-custom-blocker...
sudo ./install.sh
systemctl status cs-custom-blocker
```

## From source

:warning: requires go >= 1.13

```bash
make release
cd cs-custom-blocker-vX.X.X
sudo ./install.sh
systemctl start cs-custom-blocker
systemctl status cs-custom-blocker
```

# Configuration


The configuration file of the service is in `/etc/crowdsec/cs-custom-blocker/cs-custom-blocker.yaml`.
The default is to use SQLite backend :

```yaml
mode: custom
# This is the path to YOUR script
custom_path: /tmp/test/demo.sh
piddir: /var/run/
# How frequently new ban/unban are going to get fetch from DB
update_frequency: 10s
# Go to background ?
daemonize: true
log_mode: file
log_dir: /var/log/
log_level: info
db_config:
  ## DB type supported (mysql, sqlite)
  ## By default it using sqlite
  type: sqlite

  ## mysql options
  # db_host: localhost
  # db_username: crowdsec
  # db_password: crowdsec
  # db_name: crowdsec

  ## sqlite options
  db_path: /var/lib/crowdsec/data/crowdsec.db

  ## Other options
  flush: true
  # debug: true

```

<details>
  <summary>MySQL configuration</summary>

```yaml
mode: custom
# this is the path to YOUR script
custom_path: /tmp/test/demo.sh
piddir: /var/run/
update_frequency: 10s
daemonize: true
log_mode: file
log_dir: /var/log/
log_level: info
db_config:
  ## DB type supported (mysql, sqlite)
  type: mysql

  ## mysql options
  db_host: localhost
  db_username: crowdsec
  db_password: crowdsec
  db_name: crowdsec

  ## sqlite options
  #db_path: /var/lib/crowdsec/data/crowdsec.db

  ## Other options
  flush: true
  # debug: true
```
</details>


# How it works ?

The user-supplied script is called, when a ban is added :

 - `add <IP> <SECONDS_TO_BAN> <REASON> <JSON_OBJECT>`

when a ban is manually removed or expires :

 - `del <IP> <SECONDS_TO_BAN> <REASON> <JSON_OBJECT>`


If your script is going to perform long-running blocking action, it should put itself in the background (cs-customer-blocker waits for the script to return).


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

# Troubleshooting

 - Logs are in `/var/logcs-custom-blocker.log`
 - You can view/interact directly in the ban list with `cscli`
 - Service can be started/stopped with `systemctl start/stopcs-custom-blocker`

## Testing your blocker

> testing setup
```bash
$ sudo systemctl startcs-custom-blocker
$ tail -f /var/logcs-custom-blocker.log 
time="15-06-2020 13:44:02" level=info msg="backend type : custom"
time="15-06-2020 13:44:02" level=info msg="Create context for custom action on [/tmp/test/demo.sh]"
time="15-06-2020 13:44:02" level=info msg="custom action for [/tmp/test/demo.sh] init"
time="15-06-2020 13:44:02" level=info msg="fetching existing bans from DB"
time="15-06-2020 13:44:02" level=info msg="found 0 bans in DB"
...
```

```bash
$ sudo cscli ban add ip 1.2.3.4 60m "test ban"
$ tail -f /var/logcs-custom-blocker.log 
...
time="15-06-2020 13:45:02" level=info msg="custom [/tmp/test/demo.sh] : add ban on 1.2.3.4 for 3595 sec (test ban)"
$ sudo cscli ban del ip 1.2.3.4   
$ tail -f /var/logcs-custom-blocker.log 
...
time="15-06-2020 13:46:02" level=info msg="1 bans to flush since 2020-06-15 13:45:52.599606669 +0200 CEST m=+110.020992814"
time="15-06-2020 13:46:02" level=info msg="custom [/tmp/test/demo.sh] : del ban on 1.2.3.4"
...
```


> example 'custom script':
```bash
$ cat /tmp/test/demo.sh 
#!/bin/sh

echo "received $@"
echo $@ >> /tmp/test/traces.txt
$ cat /tmp/test/traces.txt 
add 1.2.3.4 594 test crawl {"MeasureSource":"cli","MeasureType":"ban","MeasureExtra":"","Until":"2020-06-15T13:02:52.41649833+02:00","StartIp":16909060,"EndIp":16909060,"TargetCN":"","TargetAS":0,"TargetASName":"","IpText":"1.2.3.4","Reason":"test crawl","Scenario":"","SignalOccurenceID":2}
add 1.2.3.5 594 test crawl bis {"MeasureSource":"cli","MeasureType":"ban","MeasureExtra":"","Until":"2020-06-15T13:03:12.604666128+02:00","StartIp":16909061,"EndIp":16909061,"TargetCN":"","TargetAS":0,"TargetASName":"","IpText":"1.2.3.5","Reason":"test crawl bis","Scenario":"","SignalOccurenceID":3}

```

