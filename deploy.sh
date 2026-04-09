#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — commit, push, trigger GitHub Pages deployment
#
# Usage:
#   ./deploy.sh                        # auto-commit message
#   ./deploy.sh "feat: new section"    # custom message
#
# Flow:
#   git push → GitHub Actions builds Eleventy → deploys to GitHub Pages
#   Live site: https://incidentmind.com  (custom domain via CNAME)
# ─────────────────────────────────────────────────────────────────────────────

REPO="incidentmind/website"

# ─── Commit & push ───────────────────────────────────────────────────────────
cd "$(git rev-parse --show-toplevel)"

if git diff --quiet && git diff --staged --quiet; then
  echo "✓ Nothing to commit — triggering manual Pages deploy..."
  gh workflow run deploy.yml --repo "$REPO"
else
  MSG="${1:-deploy: update site $(date '+%Y-%m-%d %H:%M')}"
  git add -A
  git commit -m "$MSG"
  git push origin main
  echo "✓ Pushed — GitHub Actions will build & deploy to GitHub Pages."
fi

# ─── Watch build ─────────────────────────────────────────────────────────────
echo ""
echo "Watching CI..."
sleep 5
gh run list --repo "$REPO" --limit 3
