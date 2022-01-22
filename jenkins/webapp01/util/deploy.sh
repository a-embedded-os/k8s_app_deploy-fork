#!/bin/bash

set -x

cd "$1" || exit 1
export COMMIT_SHA GITHUB_SHA_URL

for f in k8s/*yaml; do
  echo "Getting commit SHA for: $f"
  COMMIT_SHA=$(git log -n 1 --all --pretty=format:%H -- "$f")
  GITHUB_SHA_URL="https://github.com/$2/$3/commit/$COMMIT_SHA"
  envsubst < "$f" | kubectl diff -f -
  if [[ "$?" -eq 1 ]]; then
    echo "[INFO] Differences exist between local and online configuration. Applying local config.."
    envsubst < "$f" | kubectl apply -f -
    kubectl rollout restart deploy/"$4"
  elif [[ "$?" -gt 1 ]]; then
    echo "[ERROR] Diff between local and online configuration failed!"
  else
    echo "[INFO] No differences detected between online configuration and local."
  fi
done

