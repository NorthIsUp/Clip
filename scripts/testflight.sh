#!/bin/bash
# Archives Clip and uploads it to TestFlight (internal testers only).
# Needs Apple Development + Distribution identities for team 4BJBDQVY6M in a keychain
# and the App Store Connect key at ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8.
# --no-upload stops after archiving.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${ASC_KEY_ID:=238ATU74S4}" "${ASC_ISSUER_ID:=98c62465-9650-49ec-afe4-23318e5c1ae1}"
auth=(-allowProvisioningUpdates -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_"$ASC_KEY_ID".p8
  -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID")

rm -rf build/Clip.xcarchive build/export
# Roxas (submodule) still targets iOS 10, which current Xcode refuses to build.
# The compilation cache is keyed on content, not mtime, so CI can reuse it across fresh checkouts.
xcodebuild archive -quiet -project Clip.xcodeproj -scheme Clip -configuration Release \
  -destination generic/platform=iOS -archivePath build/Clip.xcarchive -derivedDataPath build/DerivedData "${auth[@]}" \
  CURRENT_PROJECT_VERSION="${BUILD_NUMBER:-$(date -u +%Y%m%d%H%M)}" IPHONEOS_DEPLOYMENT_TARGET=17.0 \
  COMPILATION_CACHE_ENABLE_CACHING=YES

[ "${1:-}" = --no-upload ] && exit 0
xcodebuild -exportArchive -archivePath build/Clip.xcarchive -exportOptionsPlist scripts/ExportOptions.plist \
  -exportPath build/export "${auth[@]}"
