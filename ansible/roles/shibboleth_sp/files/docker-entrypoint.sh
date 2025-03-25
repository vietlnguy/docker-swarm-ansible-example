#!/bin/bash
set -e

SHIB_CONFIG=/etc/apache2/sites-available/shib2.conf

if [ -f "$SHIB_CONFIG" ]; then
    a2ensite shib2
fi

exec "$@"
