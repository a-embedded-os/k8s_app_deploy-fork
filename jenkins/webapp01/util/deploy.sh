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
    env_dir="$(dirname "$f")"
    echo ""
    echo "========================================"
    echo "| Processing manifests in $env_dir"
    echo "| Getting commit SHA for: $f"
    echo "========================================"
    echo ""
    COMMIT_SHA=$(git log -n 1 --all --pretty=format:%H -- "$f")
    GITHUB_SHA_URL="https://github.com/$(owner_repo)/commit/$COMMIT_SHA"
    # shellcheck disable=1091
    if [[ -f $env_dir/.env ]]; then
      echo "[INFO] Sourcing .env file with Environment Variable override contents:"
      echo "============"
      cat "$env_dir/.env"
      echo "============"
      source "$env_dir/.env"
    fi
    envsubst < "$f" | kubectl diff --kubeconfig "$2" --context "$K8S_CONTEXT" -f - 2>&1
    if [[ "$?" -eq 1 ]]; then
      echo "[INFO] Differences exist between local and online configuration. APPLYING!"
      envsubst < "$f" | kubectl apply --kubeconfig "$2" --context "$K8S_CONTEXT" -f - 2>&1
      echo "[INFO] Running a rollout restart for Deployment."
      kubectl rollout restart deploy/"$1" --kubeconfig "$2" --context "$K8S_CONTEXT" 2>&1
    elif [[ "$?" -gt 1 ]]; then
      echo "[ERROR] Diff between local and online configuration FAILED!"
    else
      echo "[INFO] No differences detected between online configuration and local. DONE."
    fi
  done
}

maybe_deploy "$1"
