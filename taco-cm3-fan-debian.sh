#!/bin/bash
AUTHOR='Josh <bionicdonkey@gmail.com>'
VERSION='0.10'
#
# taco-fan install script
#

cat > /usr/bin/taco-cm3-debian.sh << \EOF
#!/bin/bash
AUTHOR='Josh <bionicdonkey@gmail.com>'
VERSION='0.10'
#
# Taco cm3 fan
#
#TEMP_FILE=/sys/class/thermal/thermal_zone0/temp
GPIOCHIP=0
FAN=22
LOW=0
HIGH=1

set_mode() {
  gpioset $1 $2=$3
}

turn_on() {
  set_mode $GPIOCHIP $FAN $HIGH
}

turn_off() {
  set_mode $ GPIOCHIP $FAN $LOW
}

trap turn_off SIGINT

#function get_temp() {
#  if [[ "$(cat $TEMP_FILE)" -gt "50000" ]]; then
#    turn_on
#  else
#    turn_off
#  fi
#}

if [[ $1 == "on" ]]; then
  turn_on
else
  turn_off
  exit 0
fi

for (( ; ; ))
do
  sleep 30s
  get_temp
done

exit 0
EOF

chmod +x /usr/bin/taco-cm3-debian.sh

cat > /lib/systemd/system/taco-cm3-debian.service << EOF
[Unit]
Description=Taco CM3 Fan

[Service]
ExecStart=/usr/bin/taco-cm3-debian.sh on
ExecStop=/usr/bin/taco-cm3-debian.sh off
Type=simple

[Install]
WantedBy=multi-user.target
EOF

systemctl enable taco-cm3-debian.service

if [ -d /run/systemd/system ]; then
  systemctl --system daemon-reload > /dev/null || true
fi

systemctl start taco-cm3-debian.service > /dev/null
