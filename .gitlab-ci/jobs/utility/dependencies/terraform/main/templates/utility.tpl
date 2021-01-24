#!/bin/bash
sudo apt-get update
sudo apt install -y apache2-utils awscli
mkdir -p data/registry data/repository/git/umbrella.git data/proxy auth

#Hash registry credentials
htpasswd -Bbn ${utility_username} ${utility_password} > $(pwd)/auth/htpasswd 
chmod 644 $(pwd)/auth/htpasswd


cat << 'EOF' > "$(pwd)"/data/repository/default.conf
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /data;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ (/.*) {
        client_max_body_size 0;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /usr/libexec/git-core/git-http-backend;
        fastcgi_param GIT_HTTP_EXPORT_ALL "";
        fastcgi_param GIT_PROJECT_ROOT /data;
        fastcgi_param REMOTE_USER $remote_user;
        fastcgi_param PATH_INFO $1;
        fastcgi_pass  unix:/var/run/fcgiwrap.socket;
    }
}
EOF

cat << EOF > "$(pwd)"/data/repository/start.sh
#!/bin/sh
spawn-fcgi -M 666 -s /var/run/fcgiwrap.socket /usr/bin/fcgiwrap &
/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
EOF

cat << EOF > "$(pwd)"/data/repository/Dockerfile
FROM nginx:alpine
EXPOSE 80
RUN apk add --no-cache git git-daemon spawn-fcgi fcgiwrap
COPY default.conf /etc/nginx/conf.d/default.conf
COPY start.sh /usr/bin/start
RUN chmod +x /usr/bin/start
CMD ["/usr/bin/start"]
EOF

docker build -t simplegit:latest "$(pwd)"/data/repository

docker run \
    -v "$(pwd)"/data/repository/git:/data \
    simplegit:latest \
    -- sh -c "cd /data/umbrella.git && chown -R nginx:nginx . && chmod -R 755 . && git init . && git update-server-info"


cat << 'EOF' > "$(pwd)"/data/proxy/tinyproxy.conf
User root
Group root

Port 8888
Listen 0.0.0.0
BindSame yes

Timeout 600

DefaultErrorFile "/usr/share/tinyproxy/default.html"
StatFile "/usr/share/tinyproxy/stats.html"
LogLevel Info
PidFile "/var/run/tinyproxy/tinyproxy.pid"

MaxClients 100
MinSpareServers 2
MaxSpareServers 5
StartServers 2
MaxRequestsPerChild 0

Allow 127.0.0.1
Allow ${vpc_cidr}

ConnectPort 22
ConnectPort 8888
ConnectPort 80
ConnectPort 443
ConnectPort 563

FilterExtended On
FilterURLs On
FilterDefaultDeny Yes
Filter "/etc/tinyproxy/whitelist"
EOF

cat << 'EOF' > "$(pwd)"/data/proxy/whitelist
index.docker.io:443
production.cloudflare.docker.com:443
registry-1.docker.io:443
auth.docker.io:443
repo1.dsop.io
repo1.dsop.io:80
registry.dsop.io:5000
registry1.dsop.io:5000
repo1.dso.mil
repo1.dso.mil:80
registry.dso.mil:5000
registry1.dso.mil:5000
rhui3.us-west-2.aws.ce.redhat.com:443
elasticloadbalancing.us-gov-west-1.amazonaws.com:443
ec2.us-gov-west-1.amazonaws.com:443
EOF

cat << 'EOF' > "$(pwd)"/data/proxy/Dockerfile
FROM alpine:latest
RUN apk add --no-cache tinyproxy
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY whitelist /etc/tinyproxy/whitelist
EXPOSE 8888
CMD ["/usr/bin/tinyproxy", "-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]
EOF

docker build -t simpleproxy:latest "$(pwd)"/data/proxy

docker run -d \
    -p 8888:8888 \
    --restart always \
    --name simpleproxy \
    simpleproxy:latest


# Load Registry and  Git

sudo su
export AWS_DEFAULT_REGION=${aws_region}

#configure docker registry
aws s3 cp s3://${pkg_s3_bucket}/${pkg_path}/images.tar.gz . --quiet
mkdir -p images
tar -xf images.tar.gz -C images/
chmod +x images/var/lib/registry
mkdir -p /data/registry/docker/
mv images/var/lib/registry/docker/registry/  /data/registry/docker/

# Run docker registry

docker run -d \
    -p 5000:5000 \
    --restart=always \
    --name registry \
    -v "$(pwd)"/auth:/auth \
    -v "$(pwd)"/data/registry:/data \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
    registry:2


#configure Git Server
aws s3 cp s3://${pkg_s3_bucket}/${pkg_path}/umbrella.tar.gz .
aws s3 cp s3://${pkg_s3_bucket}/${pkg_path}/repositories.tar.gz . --quiet
tar -xf repositories.tar.gz
tar -xf umbrella.tar.gz
rm -rf /data/repository/git/
mv umbrella repos/
for dir in repos/*    
do
    cd $dir
    REPO_URL=$(echo $(git remote get-url origin --push))
    REPO_PATH=$(echo $REPO_URL | cut -d/ -f2- | cut -d/ -f3-)
    mkdir -p /data/repository/git/$REPO_PATH
    cp -r .git /data/repository/git/$REPO_PATH/
    cd ../../
done

docker run -d \
    -p 80:80 \
    --restart always \
    --name repository \
    -v "$(pwd)"/data/repository/git:/data \
    simplegit:latest