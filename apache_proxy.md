# Use apache to act as a reverse proxy for a local server running on another port and make it secure.
## Ubuntu 20.04 and Apache 2.4
```
ServerName example.com
<VirtualHost *:80>
    ServerName example.com
    Redirect permanent / https://www.example.com/
</VirtualHost>

<VirtualHost *:443>
    #SSL Config
    ServerName example.com
    DocumentRoot /var/www/html/
    SSLEngine on
    #SSLOptions +StrictRequire
    SSLVerifyClient none
    SSLProxyEngine on
    <IfModule mime.c>
        AddType application/x-x509-ca-cert .crt
        AddType application/x-pkcs7-crl    .crl
    </IfModule>
            SetEnvIf User-Agent ".*MSIE.*"nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
    SSLProtocol TLSv1.2
    SSLCipherSuite HIGH:MEDIUM:!aNULL:+SHA1:+MD5:+HIGH:+MEDIUM

    #Do not put Directory stuff in here, does not work!
    SSLCertificateFile /etc/letsencrypt/live/www.example.com/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/www.example.com/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
    SSLCertificateChainFile /etc/letsencrypt/live/www.example.com/chain.pem
</VirtualHost>

#Require SSL everytwhere
<Directory /var/www/html>
    SSLRequireSSL
</Directory>

# proxy a local server running on port 8080 to www.example.com/program/
#   for qbittorrent-nox
#   https://github.com/qbittorrent/qBittorrent
ProxyRequests off
<Proxy *>
    allow from all
</Proxy>
RewriteEngine On
RewriteRule ^/gui/?(.*)$ /program/$1 [P]
<Location /torrent/>
    ProxyPass http://127.0.0.1:8080/
    ProxyPassReverse http://127.0.0.1:8080/
</Location>
```

## CentOS 7 and Apache 2.4

```
<VirtualHost *:80>
    Redirect permanent / https://www.example.com/
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot /var/www/html/
    SSLEngine on
    SSLProxyEngine On
    SSLCertificateFile /etc/httpd/conf/apache_ssl_cert.crt
    SSLCertificateKeyFile /etc/httpd/conf/apache_ssl_cert.key
    SSLVerifyClient none
    SSLProxyEngine off
    <IfModule mime.c>
        AddType application/x-x509-ca-cert .crt
        AddType application/x-pkcs7-crl    .crl
    </IfModule>
    SetEnvIf User-Agent ".*MSIE.*"  nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
    SSLProtocol TLSv1.2
    SSLCipherSuite HIGH:MEDIUM:!aNULL:+SHA1:+MD5:+HIGH:+MEDIUM
</VirtualHost>

# Section for ruTorrent
#   https://github.com/Novik/ruTorrent
<Location /subdir/>
    SSLRequireSSL
    AuthType Basic
    AuthName "Please Enter Password"
    AuthBasicProvider file
    AuthUserFile /etc/httpd/conf/.htpasswd
    Require valid-user
    CacheDisable on
    ProxyPass         http://localhost:8080/ retry=0
    ProxyPassReverse  http://localhost:8080/
    SetOutputFilter   proxy-html
    ProxyHTMLURLMap   http://localhost:8080/
</Location>
RewriteRule ^/subdir$ /subdir/ [R]
```
