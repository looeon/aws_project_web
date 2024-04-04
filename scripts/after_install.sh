#!/bin/bash

# Apache 서비스 시작
echo "Configure Apache settings..."
sudo cat <<EOF1 > /etc/httpd/conf/workers.properties
worker.list=worker1
worker.worker1.port=8009
worker.worker1.host="three-tier-alb-app-463482535.ap-northeast-2.elb.amazonaws.com"
worker.worker1.type=ajp13
worker.worker1.lbfactor=1
EOF1
cd /etc/httpd/conf && sudo rm -f httpd.conf
sudo cat <<EOF2 > /etc/httpd/conf/httpd.conf
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
LoadModule jk_module modules/mod_jk.so
JkWorkersFile /etc/httpd/conf/workers.properties
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
JkLogFile logs/mod_jk.log
JkLogLevel info
JkShmFile run/mod_jk.shm
<VirtualHost *:80>
 ServerName "three-tier-alb-web-1555250238.ap-northeast-2.elb.amazonaws.com"
  JkMount /*.jsp worker1
  JkMount /*.json worker1
  JkMount /*.xml worker1
  JkMount /*.do worker1
  JkMount /*.jspx worker1
</VirtualHost>
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOF2