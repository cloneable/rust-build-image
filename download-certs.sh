#!/usr/bin/env bash
set -euo pipefail

DEBFILE=ca-certificates_20241223_all.deb
SHA256SUM=bb96f2467c71323e738349080520689e4697df88c7ee90a83e9bcff1d29f3f5d

curl "https://ftp-stud.hs-esslingen.de/debian/pool/main/c/ca-certificates/${DEBFILE}" --output ca-certificates_all.deb
echo "${SHA256SUM} *ca-certificates_all.deb" | sha256sum --check
