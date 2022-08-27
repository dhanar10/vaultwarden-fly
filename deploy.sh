#!/usr/bin/env bash

# Requires: docker, flyctl

set -e
set -o pipefail

APP_NAME="$1"

ADMIN_TOKEN="$(openssl rand -base64 48)"

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT
pushd $TEMP_DIR
openssl genrsa -out rsa_key.pem 2048
openssl rsa -in rsa_key.pem -outform PEM -pubout -out rsa_key.pub.pem
RSA_KEY_TGZ="$(tar zcvf - rsa_key* | base64)"
popd

cat << EOF  > fly.toml
app = "$APP_NAME"
kill_signal = "SIGINT"
kill_timeout = 5
processes = []

[env]
  DATABASE_MAX_CONNS = 7
  DOMAIN = "https://$APP_NAME.fly.dev"
  IP_HEADER = "X-Forwarded-For"
  # Treat filesystem is ephemeral, disable attachment
  ORG_ATTACHMENT_LIMIT = 0
  USER_ATTACHMENT_LIMIT = 0
  # This is a private instance, disable sign ups (use /admin to invite users)
  SIGNUPS_ALLOWED = false

[experimental]
  allowed_public_ports = []
  auto_rollback = true

[[services]]
  http_checks = []
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"
  script_checks = []
  [services.concurrency]
    hard_limit = 25
    soft_limit = 20
    type = "connections"

  [[services.ports]]
    force_https = true
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

  [[services.tcp_checks]]
    grace_period = "1s"
    interval = "15s"
    restart_limit = 0
    timeout = "2s"
EOF

flyctl apps create --name "$APP_NAME"
flyctl postgres create --name "$APP_NAME-db" --region sin --vm-size shared-cpu-1x --initial-cluster-size 1 --volume-size 1  # Use free allowance
flyctl postgres attach "$APP_NAME-db" --app "$APP_NAME"

flyctl secrets set --app "$APP_NAME" \
    ADMIN_TOKEN="$ADMIN_TOKEN" \
    RSA_KEY_TGZ="$RSA_KEY_TGZ" >/dev/null   # XXX Hide config set ADMIN_TOKEN output

flyctl deploy --app "$APP_NAME"

cat << EOF
Token for the admin interface is:

$ADMIN_TOKEN

Keep it in a safe place!
EOF

