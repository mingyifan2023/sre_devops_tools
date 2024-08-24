


# 二进制安装nginx 和使用Certbot获取免费ssl


# 步骤 1：安装依赖项
# 在开始之前，确保您的系统上已安装必要的依赖项。以 Ubuntu 为例，可以使用以下命令：

# bash
sudo yum update 
sudo yum  install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
步骤 2：下载 Nginx 源码
# 访问 Nginx 的官方网站 获取最新版本的下载链接，然后使用 wget 下载。例如：

# wget http://nginx.org/download/nginx-1.22.0.tar.gz
# tar -zxvf nginx-1.22.0.tar.gz
# cd nginx-1.22.0



# 步骤 3：配置 Nginx 编译选项
# 在编译 Nginx 时，确保启用 HTTPS 支持。可以通过 --with-http_ssl_module 来实现：
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module;


# 步骤 4：编译和安装 Nginx

make && make install

# 步骤 5：获取 SSL 证书
# 您可以使用 Let's Encrypt 免费获取 SSL 证书，或者从其他 CA（证书颁发机构）购买 SSL 证书。以下是使用 Certbot 获取 Let’s Encrypt 证书的示例：


sudo yum -y install certbot
sudo certbot certonly --standalone -d yourdomain.com


# 步骤 6：配置 Nginx 使用 SSL

# 详见配置文件 nginx.conf


步骤 7：启动 Nginx


sudo /usr/local/nginx/sbin/nginx

or 

#/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf


如果 Nginx 已经在运行，可以使用以下命令重新加载配置：


sudo /usr/local/nginx/sbin/nginx -s reload

or 

sudo kill -9 $(lsof -i:80 -t) 

然後再啓動

# 总结
# 通过以上步骤，您可以成功通过源码安装 Nginx 并配置 HTTPS。请记得定期更新 SSL 证书，并保持 Nginx 及其模块的更新，以确保安全性。



# 下面就是完整可直接使用的配置文件

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  yourdomain;

        # Redirect HTTP to HTTPS
        return 301 https://$host$request_uri;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
                     proxy_pass http://127.0.0.1:8319;  # 替换为您的后端服务地址
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    # HTTPS server
    server {
        listen       443 ssl;
        server_name  localhost;

        ssl_certificate      /etc/letsencrypt/live/yourdomain/fullchain.pem;  # 替换为您的证书路径
        ssl_certificate_key  /etc/letsencrypt/live/yourdomain/privkey.pem;     # 替换为您的私钥路径

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        location / {
                     proxy_pass http://127.0.0.1:8319;  # 替换为您的后端服务地址
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

}
