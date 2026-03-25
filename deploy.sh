#!/usr/bin/env bash
set -euo pipefail

# ─── Build ────────────────────────────────────────────────────────────────────
echo "→ Building site..."
npm run build

# ─── Commit & push ───────────────────────────────────────────────────────────
cd "$(git rev-parse --show-toplevel)"

if git diff --quiet && git diff --staged --quiet; then
  echo "✓ Nothing to commit — triggering manual deploy..."
  gh workflow run deploy.yml --repo incidentmind/website
else
  MSG="${1:-deploy: update site $(date '+%Y-%m-%d %H:%M')}"
  git add -A
  git commit -m "$MSG"
  git push origin main
  echo "✓ Pushed — GitHub Actions will deploy automatically."
fi

# ─── Watch ───────────────────────────────────────────────────────────────────
echo ""
echo "Watching deploy..."
sleep 5
gh run list --repo incidentmind/website --limit 3
