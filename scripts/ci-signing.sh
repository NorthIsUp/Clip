#!/bin/bash
# CI only: installs the App Store Connect key and the development + distribution identities from secrets.
set -euo pipefail
: "${ASC_KEY_ID:?}" "${ASC_KEY_P8:?}" "${DEV_P12:?}" "${DIST_P12:?}" "${P12_PASSWORD:?}" "${RUNNER_TEMP:?}"
mkdir -p ~/.appstoreconnect/private_keys
printf '%s' "$ASC_KEY_P8" > ~/.appstoreconnect/private_keys/AuthKey_"$ASC_KEY_ID".p8

keychain="$RUNNER_TEMP/signing.keychain-db" pass=$(uuidgen)
security create-keychain -p "$pass" "$keychain"
security set-keychain-settings -lut 21600 "$keychain"
security unlock-keychain -p "$pass" "$keychain"
# Identities read as invalid until the WWDR intermediate is in the keychain too.
curl -fsSL -o "$RUNNER_TEMP/wwdr.cer" https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer
security import "$RUNNER_TEMP/wwdr.cer" -k "$keychain"
for p12 in "$DEV_P12" "$DIST_P12"; do
  printf '%s' "$p12" | base64 -D > "$RUNNER_TEMP/id.p12"
  security import "$RUNNER_TEMP/id.p12" -f pkcs12 -k "$keychain" -P "$P12_PASSWORD" -T /usr/bin/codesign
done
rm "$RUNNER_TEMP/id.p12"
security set-key-partition-list -S apple-tool:,apple: -k "$pass" "$keychain" >/dev/null
security list-keychains -d user -s "$keychain" login.keychain-db
