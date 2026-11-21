#!/usr/bin/env nu
# mkcd.nu - Create a directory and cd into it
# Usage: ./mkcd.nu <directory-name>

def main [directory: string] {
  ^mkdir -p $directory
  cd $directory
  print $"Created and entered: (pwd)"
}
