#!/usr/bin/env bash
# Push the site and wait until sendbetter.ai actually serves the new version.
#
#   ./deploy.sh "commit message"
#
# GitHub Pages builds in ~30s. Cloudflare caches the HTML at its edge and
# refreshes a little after that, so "pushed" and "live" are not the same
# moment. This waits for the second one.

set -euo pipefail
cd "$(dirname "$0")"

REPO="Mike-R-B-Lab/sendbetter_website"
DOMAIN="sendbetter.ai"
ORIGIN_IP="185.199.108.153"   # GitHub Pages, used to read past Cloudflare

if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  git commit -q -m "${1:-Update site}"
  echo "committed: ${1:-Update site}"
else
  echo "no local changes to commit"
fi

git push -q origin main
echo "pushed $(git rev-parse --short HEAD)"

printf 'waiting for GitHub Pages build'
for _ in $(seq 1 40); do
  status=$(gh api "repos/$REPO/pages/builds/latest" --jq .status 2>/dev/null || echo "?")
  [ "$status" = "built" ] && { echo " → built"; break; }
  [ "$status" = "errored" ] && { echo " → ERRORED"; exit 1; }
  printf '.'; sleep 5
done

# Compare what Cloudflare serves against GitHub's own copy. Equal = fully live.
origin=$(curl -sS --resolve "$DOMAIN:80:$ORIGIN_IP" "http://$DOMAIN/" | shasum | cut -d' ' -f1)
printf 'waiting for Cloudflare edge'
for _ in $(seq 1 40); do
  live=$(curl -sS "https://$DOMAIN/?cb=$RANDOM$RANDOM" | shasum | cut -d' ' -f1)
  if [ "$live" = "$origin" ]; then
    echo " → live at https://$DOMAIN"
    exit 0
  fi
  printf '.'; sleep 10
done

echo
echo "Still serving an older copy after ~7 min."
echo "Purge it: Cloudflare → $DOMAIN → Caching → Configuration → Purge Everything"
exit 1
