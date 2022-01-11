#!/bin/bash

set -x

cd "$1"

for f in k8s/*yaml; do
  echo "Getting commit SHA for: $f"
  export COMMIT_SHA="$(git log -n 1 --all --pretty=format:%H -- $f)"
  envsubst < "$f" | kubectl apply -f -
done

kubectl rollout restart deploy/p9-react-app
