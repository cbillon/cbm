#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="${1:-new52}"
DEBUG=false
echo project: "$PROJECT"
info PROJECT: "$PROJECT" debug: "$DEBUG"
PLUGIN="${1:-tool_datewatch}"

get_project_conf "$PROJECT"

cd ~/cbm/plugins/"${PLUGIN}" || exit 1
git rev-parse --git-dir > /dev/null 2>&1 || {
  echo "❌ This script must be run inside a Git repository." >&2
  exit 1
}

# --- Local branches --------------------------------------------------
mapfile -t local_branches < <(
  git for-each-ref --format='%(refname:short)' refs/heads/
)

for branch in "${local_branches[@]}"; do
  echo "Branch: $branch"
  [[ "$branch" =~ ^MOODLE_[0-9]{3}_STABLE|main|master$ ]] && {
    success "${plugin}" "$branch"
    git checkout "$branch" --quiet
    mapfile -t commits < <(
      git rev-list "$branch"
    )
    for commit in "${commits[@]}"; do
      git checkout "$commit" --quiet
      rgx='^.*version = ([0-9]{10});.*$'
      #echo rgx: $rgx
      cat version.php | grep -E ^.*supported[[:space:]]=[[:space:]]([0-9]{10});.*$
      echo $res 
      #${BASH_REMATCH[0]}
    done
  }
done

