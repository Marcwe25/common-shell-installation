#!/bin/bash
sudo -i
apt --assume-yes install software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt --assume-yes update
apt --assume-yes install python3.9