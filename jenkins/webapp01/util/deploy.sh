#!/bin/bash

set -x

export COMMIT_SHA GITHUB_SHA_URL

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1; pwd -P)"

function owner_repo {
  git config --get remote.origin.url | awk -F: '{print $2}' | sed -e "s/\.git//" | \
    awk -F/ '{print $(NF-1)"/"$NF}'
}

function maybe_deploy {
  for f in "$SCRIPTPATH"/../k8s/*/*yaml; do
    echo "Getting commit SHA for: $f"
    COMMIT_SHA=$(git log -n 1 --all --pretty=format:%H -- "$f")
    GITHUB_SHA_URL="https://github.com/$(owner_repo)/commit/$COMMIT_SHA"
    # shellcheck disable=1091
    [[ -f $(dirname "$f")/.env ]] && source "$(dirname "$f")/.env"
    envsubst < "$f" | kubectl diff -f - 2>&1
    if [[ "$?" -eq 1 ]]; then
      echo "[INFO] Differences exist between local and online configuration. Applying local config.."
      envsubst < "$f" | kubectl apply -f - 2>&1
      kubectl rollout restart deploy/"$1" 2>&1
    elif [[ "$?" -gt 1 ]]; then
      echo "[ERROR] Diff between local and online configuration failed!"
    else
      echo "[INFO] No differences detected between online configuration and local. No-op."
    fi
  done
}

maybe_deploy "$1"
