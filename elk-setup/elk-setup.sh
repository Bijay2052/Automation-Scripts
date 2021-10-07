#! /bin/bash

echo "change to root"
sudo su

if [ -f /etc/redhat-release ]; then
    echo "The distribution is redhat/centos"

    echo "install java"
    yum install java-1.8.0-openjdk-devel -y

    echo "import elastic repo"
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

    echo "installing rpm repository"
    touch /etc/yum.repos.d/elasticsearch.repo
    cat > /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

    yum install --enablerepo=elasticsearch elasticsearch -y

    echo "starting the elasticsearch service"
    systemctl daemon-reload
    systemctl enable elasticsearch.service
    systemctl start elasticsearch.service

    echo "Checking if elasticsearch is running or not"
    yum install curl -y
    curl -X GET "localhost:9200/?pretty"

    echo "Installing kibana"
    yum install kibana -y

    echo "starting the kibana service"
    systemctl daemon-reload
    systemctl enable kibana.service
    systemctl start kibana.service
    setsebool httpd_can_network_connect 1 -P

    echo "Installing nginx"
    yum install nginx httpd-tools -y
    touch /etc/nginx/conf.d/kibana.conf
    cat > /etc/nginx/conf.d/kibana.conf << "EOF"
server {
    listen 80;

    server_name <public ip of the server>;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.kibana-user;

    location / {
        proxy_pass http://127.0.0.1:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade '$http_upgrade';
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host '$host';
        proxy_cache_bypass '$http_upgrade';
    }
}
EOF

    htpasswd -bc /etc/nginx/.kibana-user admin admin
    systemctl enable nginx
    systemctl start nginx

    echo "Installing logstash"
    yum install logstash -y


else [ -f /etc/lsb-release ]
    echo "The distribution is debian/ubuntu"

    echo "install java"
    apt install openjdk-8-jdk -y

    echo "import elastic repo"
    apt install wget -y
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - # for debian based system
    apt install apt-transport-https -y
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

    apt update && apt install elasticsearch -y

    echo "starting the elasticsearch service"
    systemctl daemon-reload
    systemctl enable elasticsearch.service
    systemctl start elasticsearch.service

    echo "Checking if elasticsearch is running or not"
    apt install curl -y
    curl -X GET "localhost:9200/?pretty"

    echo "Installing kibana"
    apt update && apt install kibana -y

    echo "starting the kibana service"
    systemctl daemon-reload
    systemctl enable kibana.service
    systemctl start kibana.service

    echo "Installing nginx"
    apt install nginx -y
    apt install apache2-utils -y
    touch /etc/nginx/conf.d/kibana.conf
    cat > /etc/nginx/conf.d/kibana.conf << "EOF"
server {
    listen 80;

    server_name <public ip of the server>;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.kibana-user;

    location / {
        proxy_pass http://127.0.0.1:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade '$http_upgrade';
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host '$host';
        proxy_cache_bypass '$http_upgrade';
    }
}
EOF

    htpasswd -bc /etc/nginx/.kibana-user admin admin
    systemctl enable nginx
    systemctl start nginx

    echo "Installing logstash"
    apt update && apt install logstash -y

fi
