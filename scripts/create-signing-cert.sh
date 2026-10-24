#!/bin/bash
# Creates a stable self-signed code-signing certificate named
# "OpenContexts Release Signing" in the login keychain, so local builds
# signed with SIGNING_MODE=self-signed keep a stable designated requirement —
# meaning macOS Accessibility (TCC) permission survives rebuilds.
#
# Idempotent: re-running is a no-op if the certificate already exists.
set -euo pipefail

NAME="OpenContexts Release Signing"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-certificate -c "$NAME" "$KEYCHAIN" >/dev/null 2>&1; then
    echo "Certificate already exists: $NAME"
    security find-identity -p codesigning "$KEYCHAIN" | grep -F "$NAME" || true
    exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/openssl.cnf" <<CNF
[ req ]
distinguished_name = dn
x509_extensions = v3
prompt = no
[ dn ]
CN = $NAME
[ v3 ]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF

openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$tmp/key.pem" -out "$tmp/cert.pem" -days 3650 \
    -config "$tmp/openssl.cnf"

# Import cert and key separately as PEM (avoids macOS `security` choking on the
# MAC of a LibreSSL-produced PKCS#12). -T/-A let codesign use the key.
security import "$tmp/cert.pem" -k "$KEYCHAIN" -T /usr/bin/codesign -A
security import "$tmp/key.pem" -k "$KEYCHAIN" -T /usr/bin/codesign -A

# Try to pre-authorize codesign so it won't prompt on first use. Needs the
# login-keychain password; if it isn't blank this fails harmlessly and codesign
# will prompt once (click "Always Allow").
if ! security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" "$KEYCHAIN" >/dev/null 2>&1; then
    echo "NOTE: couldn't pre-authorize the key non-interactively."
    echo "      The FIRST codesign will show a keychain prompt — click \"Always Allow\"."
fi

echo "Created: $NAME"
security find-identity -p codesigning "$KEYCHAIN" | grep -F "$NAME" || true
echo
echo "Now build with stable signing:"
echo "  SIGNING_MODE=self-signed ./scripts/build-app.sh debug"
