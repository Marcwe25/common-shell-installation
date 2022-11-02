#!/bin/bash
	path2=/vagrant_data/micom
	sudo pip install python-miio

# write out current crontab
	crontab -l > /tmp/mycron
	#echo new cron into cron file
	echo "@reboot ${path2}/mirobo_command" >> /tmp/mycron
	echo "1 0 * * * ${path2}/mirobo_reset_daily" >> /tmp/mycron
	echo "* 8-19 * * * ${path2}/mirobo_script" >> /tmp/mycron
	#install new cron file
	crontab /tmp/mycron
	rm /tmp/mycron
	
