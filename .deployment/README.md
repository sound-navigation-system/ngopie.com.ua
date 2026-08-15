# ngopie.com.ua server deployment

The production document root is dedicated to this domain:

```text
/var/www/ngopie.com.ua/public_html
```

It is independent from the temporary `edvin.info` copy.

## Initial HTTP setup

On the server, from the repository root:

```bash
sudo ./.deployment/setup-server.sh
```

The script installs the Apache HTTP virtual host, publishes the static files,
sets web ownership and permissions, validates Apache, reloads it, and checks
the page, CSS, JavaScript, and logo through the local virtual host.

## HTTPS

Only after both DNS records point to the SNS VPS:

```bash
sudo certbot --apache \
  -d ngopie.com.ua \
  -d www.ngopie.com.ua \
  --redirect
```

Certbot creates the SSL virtual host and HTTPS redirect using the server's
existing Let's Encrypt configuration.
