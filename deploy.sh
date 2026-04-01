#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — commit, push, trigger Docker image build, optionally update host
#
# Usage:
#   ./deploy.sh                        # auto-commit message
#   ./deploy.sh "feat: new section"    # custom message
#
# Flow:
#   git push → GitHub Actions builds image → pushes ghcr.io/incidentmind/website:latest
#   (optional) SSH into host and run: docker compose pull && docker compose up -d
# ─────────────────────────────────────────────────────────────────────────────

REPO="incidentmind/website"

# ─── Commit & push ───────────────────────────────────────────────────────────
cd "$(git rev-parse --show-toplevel)"

if git diff --quiet && git diff --staged --quiet; then
  echo "✓ Nothing to commit — triggering manual image build..."
  gh workflow run deploy.yml --repo "$REPO"
else
  MSG="${1:-deploy: update site $(date '+%Y-%m-%d %H:%M')}"
  git add -A
  git commit -m "$MSG"
  git push origin main
  echo "✓ Pushed — GitHub Actions will build & push the Docker image."
fi

# ─── Watch build ─────────────────────────────────────────────────────────────
echo ""
echo "Watching CI..."
sleep 5
gh run list --repo "$REPO" --limit 3

# ─── (Optional) rolling update on host ───────────────────────────────────────
# Uncomment and set DEPLOY_HOST to have this script SSH into your server and
# pull the new image without downtime.
#
# DEPLOY_HOST="user@your-server-ip"
# DEPLOY_DIR="/opt/hosting"
#
# echo ""
# echo "→ Updating host..."
# ssh "$DEPLOY_HOST" \
#   "cd $DEPLOY_DIR && docker compose pull incidentmind && docker compose up -d --no-deps incidentmind"
# echo "✓ Host updated."
