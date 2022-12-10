#!/bin/bash

sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo netfilter-persistent save

sudo apt-get update &&
sudo apt-get upgrade --yes &&

sudo useradd -m -g root -G sudo -s /bin/bash -m tom
sudo echo 'tom	ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
sudo su tom

sudo apt install default-jre -y &&
sudo apt install maven wget -y &&


sudo useradd -m -U -s /bin/false -d /opt/tomcat tomcat

cd /tmp/
wget http://mirror.vorboss.net/apache/tomcat/tomcat-9 -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`

rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat9/
chown -R tomcat.tomcat /usr/local/tomcat9

rm -rf /etc/systemd/system/tomcat.service

cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target
 
[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd6 
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid 
Environment=CATALINA_HOME=/opt/tomcat 
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
 
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
 
User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always
 
[Install]
WantedBy=multi-user.target

EOT

sudo ufw allow 8080
sudo ufw allow ssh
sudo echo "yes" | ufw enable

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git
cd vprofile-project
mvn install
systemctl stop tomcat
sleep 60
rm -rf /usr/local/tomcat9/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat9/webapps/ROOT.war
systemctl start tomcat
sleep 120
cp /vagrant/application.properties /usr/local/tomcat9/webapps/ROOT/WEB-INF/classes/application.properties
systemctl restart tomcat
