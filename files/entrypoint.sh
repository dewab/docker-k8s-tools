#!/bin/sh

# Trust additional CA certs
if [ -d /ca ] && ls /ca/*.crt /ca/*.pem 1>/dev/null 2>&1; then
  echo "[+] Installing additional CA certificates from /ca"
  mkdir -p /usr/local/share/ca-certificates/custom
  cp /ca/*.crt /ca/*.pem /usr/local/share/ca-certificates/custom/ 2>/dev/null || true
  update-ca-certificates
fi

# Start socat in background
socat TCP-LISTEN:19191,fork,reuseaddr TCP:127.0.0.1:80 &

# Drop into zsh
exec zsh
