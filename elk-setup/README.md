This script automates the installation and basic setup of elk stack in the fresh server.
This script only installes elk in either rhel/centos or debian/ubuntu. First it checks the os of the system 
if it is centos if not it considers it as ubuntu. So keep in mind that the os should be either centos os ubuntu
for this script to work properly.
    It installes elasticsearch and kibana and nginx to proxy to kibana, so that we can access kibana using port 80/443.
    It uses the default configuration of ELK stack.
    Note: One thing to do before running the script is to change the public ip in server_name directive to public ip
    of the server in nginx configuration in the script. Both loop has this part so give attention to that part.