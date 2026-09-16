#!/usr/bin/env bash
# Shared helpers for syncing GitHub Project #10 (ReservaYa) Status field
# from git/PR events. Sourced by .github/workflows/project-sync.yml.
#
# Requires: gh CLI authenticated via GH_TOKEN with a PAT that has the
# 'project' scope (the default GITHUB_TOKEN cannot write to a user-owned
# Project). See docs/project-sync.md for setup.
set -euo pipefail

PROJECT_OWNER="Ryusse"
PROJECT_NUMBER=10
STATUS_FIELD="Status"

rank() {
  case "$1" in
    Backlog) echo 0 ;;
    Todo) echo 1 ;;
    "In Progress") echo 2 ;;
    "In Review") echo 3 ;;
    Done) echo 4 ;;
    *) echo -1 ;;
  esac
}

# get_status <owner> <repo> <issue_number>
# Prints the current Status option name for that issue's item in the
# project, or "Backlog" if the issue has no item / no Status set yet.
get_status() {
  local owner="$1" repo="$2" num="$3"
  gh api graphql -f query='
    query($owner:String!, $repo:String!, $num:Int!) {
      repository(owner:$owner, name:$repo) {
        issue(number:$num) {
          projectItems(first: 10) {
            nodes {
              project { number }
              fieldValueByName(name: "Status") {
                ... on ProjectV2ItemFieldSingleSelectValue { name }
              }
            }
          }
        }
      }
    }' -f owner="$owner" -f repo="$repo" -F num="$num" 2>/dev/null |
  jq -r --argjson pn "$PROJECT_NUMBER" '
    .data.repository.issue.projectItems.nodes[]?
    | select(.project.number == $pn)
    | .fieldValueByName.name // "Backlog"
  ' | head -1
}

# find_linked_issue <owner> <repo> <branch>
# Prints the number of the open issue whose linked branch matches <branch>
# (set via `gh issue develop`), if any.
find_linked_issue() {
  local owner="$1" repo="$2" branch="$3"
  gh api graphql -f query='
    query($owner:String!, $repo:String!) {
      repository(owner:$owner, name:$repo) {
        issues(first: 100, states: OPEN) {
          nodes { number linkedBranches(first: 5) { nodes { ref { name } } } }
        }
      }
    }' -f owner="$owner" -f repo="$repo" 2>/dev/null |
  jq -r --arg branch "$branch" '
    .data.repository.issues.nodes[]
    | select(.linkedBranches.nodes[]?.ref.name == $branch)
    | .number
  ' | head -1
}

# move_issue <owner> <repo> <issue_number> <target_status>
# Moves the issue's card forward to <target_status>. Never regresses a
# card that is already at or past that status.
move_issue() {
  local owner="$1" repo="$2" num="$3" target="$4"
  local url="https://github.com/${owner}/${repo}/issues/${num}"

  gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$url" >/dev/null 2>&1 || true

  local current
  current="$(get_status "$owner" "$repo" "$num")"
  current="${current:-Backlog}"

  local cur_rank tgt_rank
  cur_rank="$(rank "$current")"
  tgt_rank="$(rank "$target")"

  if [ "$tgt_rank" -le "$cur_rank" ]; then
    echo "skip $owner/$repo#$num: already '$current', not moving to '$target'"
    return 0
  fi

  echo "moving $owner/$repo#$num: '$current' -> '$target'"
  gh project item-edit "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$url" --field "$STATUS_FIELD" --value "$target"
}

# extract_issue_refs <text> <default_owner> <default_repo>
# Reads a PR title/body from stdin-free arg and prints one "owner repo num"
# line per Closes/Fixes/Resolves/Refs reference found, same-repo or
# cross-repo (owner/repo#N).
extract_issue_refs() {
  local text="$1" def_owner="$2" def_repo="$3"
  grep -oiE '(close[sd]?|fix(e[sd])?|resolve[sd]?|refs?)[[:space:]]+([A-Za-z0-9._-]+/[A-Za-z0-9._-]+)?#[0-9]+' <<<"$text" |
  grep -oE '([A-Za-z0-9._-]+/[A-Za-z0-9._-]+)?#[0-9]+' |
  while IFS= read -r ref; do
    if [[ "$ref" == *"/"* ]]; then
      local owner_repo="${ref%%#*}"
      local num="${ref##*#}"
      echo "${owner_repo%%/*} ${owner_repo##*/} $num"
    else
      echo "$def_owner $def_repo ${ref##*#}"
    fi
  done | sort -u
}
