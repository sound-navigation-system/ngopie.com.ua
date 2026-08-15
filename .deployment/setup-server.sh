#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SITE_ROOT="/var/www/ngopie.com.ua"
WEB_ROOT="$SITE_ROOT/public_html"
APACHE_SITE="/etc/apache2/sites-available/ngopie.com.ua.conf"

for command_name in apache2ctl a2ensite rsync curl; do
    command -v "$command_name" >/dev/null 2>&1 || {
        echo "Required command is missing: $command_name" >&2
        exit 1
    }
done

install -d -m 755 -o www-data -g www-data "$SITE_ROOT" "$WEB_ROOT"
install -d -m 755 -o www-data -g www-data \
    "$SITE_ROOT/.well-known" "$SITE_ROOT/.well-known/acme-challenge"

install -m 644 -o root -g root \
    "$SCRIPT_DIR/ngopie.com.ua.conf" "$APACHE_SITE"

rsync -a --delete \
    --exclude '.git/' \
    --exclude '.deployment/' \
    "$REPOSITORY_ROOT/" "$WEB_ROOT/"

find "$WEB_ROOT" -type d -exec chmod 755 {} +
find "$WEB_ROOT" -type f -exec chmod 644 {} +
chown -R www-data:www-data "$SITE_ROOT"

a2ensite ngopie.com.ua.conf >/dev/null
apache2ctl configtest
systemctl reload apache2

for path in / /css/styled.css /img/header_logo.svg /index.js; do
    curl --fail --silent --show-error \
        --header 'Host: ngopie.com.ua' \
        --output /dev/null "http://127.0.0.1${path}"
done

echo "HTTP virtual host is installed and passed local checks."
echo "After DNS points to this server, enable HTTPS with:"
echo "sudo certbot --apache -d ngopie.com.ua -d www.ngopie.com.ua --redirect"
