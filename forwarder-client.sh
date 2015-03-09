#!/bin/bash

#### CAU HINH LOGSTASH-FORWARDER TREN CLIENT ####

echo "#### BAT DAU ####"

sleep 3

### ADD repo ###
echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list

### ADD key de khac phuc loi NO PUB KEY ### Tai GPG key cho Logstash-forwarder ###
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -

### UPDATE he thong ###
sudo apt-get update

### CAI DAT LOGSTASH-FORWARDER ###
sudo apt-get install logstash-forwarder

### CAU HINH TU DONG RUN CHO LOGSTASH-FORWARDER ###
cd /etc/init.d/; sudo wget https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O logstash-forwarder

### CAP QUYEN THUC THI ###
sudo chmod +x logstash-forwarder
sudo update-rc.d logstash-forwarder defaults

### TAO THU MUC certs va COPY crt VAO THU MUC VUA TAO ###
sudo mkdir -p /etc/pki/tls/certs
sudo cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/

echo "### CAU HINH LOGSTASH-FORWARDER ###"

sleep 3

#forwarder=/etc/logstash-forwarder
#test -f forwarder.orig || cp $forwarder $forwarder.orig

cat << EOF > /etc/logstash-forwarder
{
  "network": {
    "servers": [ "10.145.37.106:5000" ],
    "timeout": 15,
    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"
  },
  "files": [
    {
      "paths": [
        "/var/log/syslog",
        "/var/log/auth.log"
       ],
      "fields": { "type": "syslog" }
    }
   ]
}
EOF

echo "### KHOI DONG LAI DICH VU ###"
sudo service logstash-forwarder restart

sleep 3

echo "### KET THUC QUA TRINH CAI DAT VA CAU HINH ###"
