#!/bin/bash

source /badge/bin/badge_vars.sh

### set honeypot DHCP scope from mac address
scope=$($P/mac2dhcp.sh | sed 's/\.0$//')
    #"data": "192.168.0.1"
echo '
{

"Dhcp4":
{
  "interfaces-config": {
    "interfaces": [ "wlan0" ]
  },

  "lease-database": {
    "type": "memfile",
		"persist": true,
		"name": "/mnt/ram/kea-leases4-honeypot.csv",
		"lfc-interval": 1800
  },
	"option-data": [
	{
		"name": "domain-name-servers",
		"data": "10.254.206.1"
		}, {
		"name": "routers",
		"data": "10.254.206.1"
	}
	],

  "expired-leases-processing": {
    "reclaim-timer-wait-time": 10,
    "flush-reclaimed-timer-wait-time": 25,
    "hold-reclaimed-time": 3600,
    "max-reclaim-leases": 100,
    "max-reclaim-time": 250,
    "unwarned-reclaim-cycles": 5
  },

  "valid-lifetime": 4000,

  "subnet4": [
  {    "subnet": "10.254.206.0/24",
       "pools": [ { "pool": "10.254.206.91 - 10.254.206.253" } ] }
  ]

},

"Logging":
{
  "loggers": [
    {
      "name": "kea-dhcp4",
      "output_options": [
          {
            "output": "/mnt/ram/kea-dhcp4-honeypot.log"
          }
      ],
      "severity": "INFO",
      "debuglevel": 0
    },
  ]
}

}
' > $KEA_CONF_PATH/$KEA_HONEYPOT_CONF

perl -p -i -e "s/\"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\"/\"$scope.1\"/g" $KEA_CONF_PATH/$KEA_HONEYPOT_CONF
  #{    "subnet": "192.168.0.0/24",
perl -p -i -e "s/\"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}\"/\"$scope.0\/24\"/g" $KEA_CONF_PATH/$KEA_HONEYPOT_CONF
       #"pools": [ { "pool": "192.168.0.2 - 192.168.0.200" } ] }
rand=$((65 + RANDOM % 140))
perl -p -i -e "s/\"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+\-\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\"/\"$scope.$rand - $scope.253\"/g" $KEA_CONF_PATH/$KEA_HONEYPOT_CONF


