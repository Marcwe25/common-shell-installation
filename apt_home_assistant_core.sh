#!/bin/bash

#dependencies
sudo apt-get install -y python3 python3-dev python3-venv python3-pip bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5 libturbojpeg0-dev tzdata

#CREATE ACCOUNT
sudo useradd -rm homeassistant

#directory for Home Assistant Core
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant

#virtual environment
sudo -u homeassistant -H -s
cd /srv/homeassistant
python3 -m venv .
source bin/activate

#install required Python package.
python3 -m pip install wheel

#install Home Assistant Core
pip3 install homeassistant

#Start Home Assistant Core
hass

#reach your installation on http://homeassistant.local:8123, or  http://localhost:8123 or http://X.X.X.X:8123 
