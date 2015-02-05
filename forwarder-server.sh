#!/bin/bash

#### CAI DAT VA CAU HINH LOGSTASH TREN server dung co che FORWARDER ####

echo "#### BAT DAU ###"
sleep 3

echo "########## Cai dat Java7 ###########"
sleep 3
#### ADD repo, update va cai dat ####
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java7-installer


echo "########## Cai dat Elasticsearch ###########"
sleep 3
#### Add key va repo ####
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb http://packages.elasticsearch.org/elasticsearch/1.1/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list

#### update, cai dat, cau hinh elasticsearch ####
sudo apt-get update
sudo apt-get -y install elasticsearch=1.1.1
echo "script.disable_dynamic: true" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: localhost" >> /etc/elasticsearch/elasticsearch.yml
sudo service elasticsearch restart
sudo update-rc.d elasticsearch defaults 95 10

echo "########## cai dat Kibana #############"
sleep 3

### tai kibana, giai nen ###
cd ~; wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz
tar xvf kibana-3.0.1.tar.gz

### cau hinh ###
#sudo vi ~/kibana-3.0.1/config.js
sed -i 's/9200/80/g' ~/kibana-3.0.1/config.js
sudo mkdir -p /var/www/kibana3
sudo cp -R ~/kibana-3.0.1/* /var/www/kibana3/

echo "########## cai dat va cau hinh Nginx ############"
sleep 3
### cai dat, cau hinh nginx ###

sudo apt-get install nginx -y
cd ~; wget https://gist.githubusercontent.com/thisismitch/2205786838a6a5d61f55/raw/f91e06198a7c455925f6e3099e3ea7c186d0b263/nginx.conf
sed -i 's/kibana.myhost.org/FQDN/g' nginx.conf
sed -i 's/usr\/share\/kibana3/var\/www\/kibana3/g' nginx.conf
sudo cp nginx.conf /etc/nginx/sites-available/default
#sudo apt-get install apache2-utils -y
#sudo htpasswd -c /etc/nginx/conf.d/kibana.myhost.org.htpasswd uycn
sudo service nginx restart

echo "########### cai dat va cau hinh Logstash ############"
sleep 3

echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
sudo apt-get update
sudo apt-get install logstash=1.4.2-1-2c0f5a1

echo "########### SSL certificates ############"

sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private

cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt

echo "#### Cau hinh Logstash ####"
sleep 3

#### tao file input ####

cat << EOF > /etc/logstash/conf.d/01-lumberjack-input.conf
input {
  lumberjack {
    port => 5000
    type => "logs"
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
EOF

#### tao file filter ####

cat << EOF > /etc/logstash/conf.d/10-syslog.conf
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    syslog_pri { }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
EOF

#### tao file output ####

cat << EOF > /etc/logstash/conf.d/30-lumberjack-output.conf
output {
  elasticsearch { host => localhost }
  stdout { codec => rubydebug }
}
EOF

#### khoi dong lai dich vu ####
sudo service logstash restart

#### day crt sang client ####
scp /etc/pki/tls/certs/logstash-forwarder.crt root@172.16.69.220:/tmp

echo "#### XONG ROI !! CHEN' THOI :) ####"
