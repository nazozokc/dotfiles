#!/usr/bin/env nu
# gh-new.nu - Create a new GitHub repo, clone it, and cd into it
# Usage: ./gh-new.nu <repo-name> [description]

def main [repo: string, description?: string] {
  print $"Creating GitHub repository: ($repo)"

  let desc = ($description | default "")
  if ($desc | is-not-empty) {
    ^gh repo create $repo --public --description $desc --clone
  } else {
    ^gh repo create $repo --public --clone
  }

  cd $repo

  print ""
  print "Repository created and cloned."
  print $"Current directory: (pwd)"
}
