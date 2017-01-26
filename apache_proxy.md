# Use apache 2.4 to act as a reverse proxy for a local server running on another port and make it secure.

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
