#!/bin/bash
DATABASE_PASS='aDmin123!'

sudo -i
# installing repo
sudo yum install libaio ncurses-compat-libs wget unzip git -y
sudo mkdir /tmp/mytmp01
cd /tmp/mytmp01
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo wget https://repo.mysql.com//mysql80-community-release-el7-6.noarch.rpm
sudo yum install mysql80-community-release-el7-6.noarch.rpm -y
sudo yum install mysql-community-server -y

# starting & enabling mysqld
sudo systemctl start mysqld
sudo systemctl enable mysqld

cd /tmp/
git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git


TMPPASS=$(sudo grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //')
sudo mysql -u root -p${TMPPASS}  --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_PASS}';flush privileges;"

#restore the dump file for the application
#sudo mysql -u root -p${DATABASE_PASS} -e "UPDATE mysql.user SET Password=md5('${DATABASE_PASS}') WHERE user='root'"
sudo mysql -u root -p${DATABASE_PASS} -e "DELETE FROM mysql.user WHERE user='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p${DATABASE_PASS} -e "DELETE FROM mysql.user WHERE user=''"
sudo mysql -u root -p${DATABASE_PASS} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p${DATABASE_PASS} -e "FLUSH PRIVILEGES"
sudo mysql -u root -p${DATABASE_PASS} -e "create database accounts"
sudo mysql -u root -p${DATABASE_PASS} -e "create user 'admin'@'%' identified by '${DATABASE_PASS}'"
sudo mysql -u root -p${DATABASE_PASS} -e "grant all privileges on *.* to 'admin'@'%'"
sudo mysql -u root -p${DATABASE_PASS} accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p${DATABASE_PASS} -e "FLUSH PRIVILEGES"

# Restart mysqld
sudo systemctl restart mysqld


#starting the firewall and allowing the mysqld to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mysqld
