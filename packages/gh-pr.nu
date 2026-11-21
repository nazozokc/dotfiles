#!/usr/bin/env nu
# gh-pr.nu - Create and view GitHub PR
# Usage: ./gh-pr.nu [base-branch] [--web]

def main [base?: string, --web] {
  let base_branch = ($base | default "main")

  print $"Creating PR to ($base_branch)..."
  if $web {
    ^gh pr create --base $base_branch --fill --web
  } else {
    ^gh pr create --base $base_branch --fill
  }

  print ""
  print "PR created. Opening..."
  ^gh pr view --web
}
