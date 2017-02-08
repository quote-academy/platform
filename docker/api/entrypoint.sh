#!/bin/bash

set -e

mkdir -p /srv/api/web/uploads

(setfacl -Rn -m u:www-data:rwX -m u:`whoami`:rwX -m mask:rwX /srv/api/var/cache /srv/api/var/logs /srv/api/web/uploads || true) &>/dev/null
(setfacl -dRn -m u:www-data:rwX -m u:`whoami`:rwX -m mask:rwX /srv/api/var/cache /srv/api/var/logs /srv/api/web/uploads || true) &>/dev/null
(setfacl -dRn -m u:www-data:rwX -m u:`whoami`:rwX -m mask:rwX /srv/api/var/sessions /srv/api/var/sessions /srv/api/web/uploads || true) &>/dev/null

chown -R www-data:www-data /srv/api/web/uploads

composer config -g github-oauth.github.com 0905db4776fcda6d9b5e535dec21dd592f381aca

exec "$@"
