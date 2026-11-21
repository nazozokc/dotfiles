#!/usr/bin/env nu
# port-check.nu - Show listening ports and their processes
# Usage: ./port-check.nu [port-number]

def main [port?: string] {
  if ($port | is-not-empty) {
    print $"Checking port: ($port)"
    print "-----------------------------------------"

    if not (which ss | is-empty) {
      # ss は待受が無くても終了コード 0 + ヘッダだけを返すので stdout を見る
      let result = (^ss -H -tlnp $"sport = :($port)" | complete)
      if ($result.stdout | str trim | is-empty) {
        print $"No process listening on port ($port)"
      } else {
        print $result.stdout
      }
      if not ($result.stderr | str trim | is-empty) {
        print -e $result.stderr
      }
      if $result.exit_code != 0 {
        exit $result.exit_code
      }
    } else if not (which lsof | is-empty) {
      let result = (^lsof -i $":($port)" -P -n | complete)
      if ($result.stdout | str trim | is-empty) {
        print $"No process listening on port ($port)"
      } else {
        print $result.stdout
      }
      if not ($result.stderr | str trim | is-empty) {
        print -e $result.stderr
      }
      if $result.exit_code != 0 {
        exit $result.exit_code
      }
    } else {
      print -e "Error: Neither ss nor lsof found"
      exit 1
    }
  } else {
    print "========================================="
    print "  Listening Ports"
    print "========================================="
    print ""

    if not (which ss | is-empty) {
      ^ss -tlnp
    } else if not (which lsof | is-empty) {
      ^lsof -i -P -n | ^grep LISTEN
    } else {
      print -e "Error: Neither ss nor lsof found"
      exit 1
    }
  }
}
