#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

# First find out if this was called from symlink,
# then find the real path of parent directory.
# This is needed because macOS does not have GNU realpath.
thisfile=$( readlink "${BASH_SOURCE[0]}" ) || thisfile="${BASH_SOURCE[0]}"
cd "$( cd "$( dirname "$thisfile" )/" && pwd -P )"

PROJECT="${1:-new52}"
DEBUG=false
echo project: "$PROJECT"

plugins=($(jq -r ".plugins[].name" projects/"$PROJECT"/"$PROJECT".json | tr "\n" " "))

echo nb:"${#plugins[@]}"
i=0
IFS=" "
for plugin in ${plugins[*]}
do
  info "$i" "${plugin}"
  cd ~/cbm/plugins/"${plugin}" || exit 1
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
      git checkout "$branch"
      mapfile -t commits < <(
        git rev-list "$branch"
      )
      for commit in "${commits[@]}"; do
        git checkout "$commit"
        cat version.php | grep 
      done
    }
  done

  ((++i))
done

exit


# --------------------------------------------------------------------
# 2.  Populate the arrays
# --------------------------------------------------------------------
# --- Local branches --------------------------------------------------
mapfile -t local_branches < <(
    git for-each-ref --format='%(refname:short)' refs/heads/
)


#iterate over all branches

for branch in "${local_branches[@]}"; do
    echo "Branch: $branch"
    [[ "$branch" =~ ^MOODLE_[0-9]{3}_STABLE|main|master$ ]] && success "$branch" || error "$branch"
done

success "That's All!"