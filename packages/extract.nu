#!/usr/bin/env nu
# extract.nu - Extract various archive files
# Usage: ./extract.nu <archive-file>

def usage [] {
  print "Usage: extract <archive-file>"
  print ""
  print "Supported formats:"
  print "  .tar.bz2  .tar.gz  .tar.xz  .tar.zst"
  print "  .tar      .tbz2    .tgz     .txz"
  print "  .zip      .rar     .7z      .gz"
  print "  .bz2      .xz      .zst     .lz"
  print "  .lzma     .Z       .deb     .rpm"
}

def main [file?: string] {
  if ($file | is-empty) {
    usage
    exit 1
  }

  if not ($file | path exists) {
    print -e $"Error: File '($file)' not found"
    exit 1
  }

  print $"Extracting: ($file)"

  # 先頭から順に一致させる (.tar.gz を .gz より先に見る)
  let extractors = [
    { suffix: ".tar.bz2",  cmd: "tar",       args: ["xjf"] }
    { suffix: ".tbz2",     cmd: "tar",       args: ["xjf"] }
    { suffix: ".tar.gz",   cmd: "tar",       args: ["xzf"] }
    { suffix: ".tgz",      cmd: "tar",       args: ["xzf"] }
    { suffix: ".tar.xz",   cmd: "tar",       args: ["xJf"] }
    { suffix: ".txz",      cmd: "tar",       args: ["xJf"] }
    { suffix: ".tar",      cmd: "tar",       args: ["xf"] }
    { suffix: ".bz2",      cmd: "bunzip2",   args: [] }
    { suffix: ".gz",       cmd: "gunzip",    args: [] }
    { suffix: ".xz",       cmd: "unxz",      args: [] }
    { suffix: ".zst",      cmd: "unzstd",    args: [] }
    { suffix: ".lz",       cmd: "lzip",      args: ["-d"] }
    { suffix: ".lzma",     cmd: "unlzma",    args: [] }
    { suffix: ".Z",        cmd: "uncompress", args: [] }
    { suffix: ".zip",      cmd: "unzip",     args: [] }
    { suffix: ".rar",      cmd: "unrar",     args: ["x"] }
    { suffix: ".7z",       cmd: "7z",        args: ["x"] }
  ]

  if ($file | str ends-with ".tar.zst") {
    # macOS の tar は --zstd 非対応の場合があるため unzstd で展開する
    ^unzstd -c $file | ^tar xf -
  } else {
    let found = ($extractors | where { |e| $file | str ends-with $e.suffix } | first)

    if ($found | is-not-empty) {
      ^$found.cmd ...$found.args $file
    } else if ($file | str ends-with ".deb") {
      if (which dpkg | is-empty) {
        print -e "Error: dpkg not found"
        exit 1
      }
      ^dpkg-deb -x $file ($file | path parse | get stem)
    } else if ($file | str ends-with ".rpm") {
      if (which rpm2cpio | is-empty) {
        print -e "Error: rpm2cpio not found"
        exit 1
      }
      ^rpm2cpio $file | ^cpio -idmv
    } else {
      print -e $"Error: Unknown archive format '($file)'"
      exit 1
    }
  }

  print "Extraction complete."
}
