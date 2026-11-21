#!/usr/bin/env nu
# port-check.nu - Show listening ports and their processes
# Usage: ./port-check.nu [port-number]

def main [port?: string] {
  if ($port | is-not-empty) {
    print $"Checking port: ($port)"
    print "-----------------------------------------"

    if not (which ss | is-empty) {
      try {
        ^ss -tlnp $"sport = :($port)" e> /dev/null
      } catch {
        print $"No process listening on port ($port)"
      }
    } else if not (which lsof | is-empty) {
      try {
        ^lsof -i $":($port)" -P -n e> /dev/null
      } catch {
        print $"No process listening on port ($port)"
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
