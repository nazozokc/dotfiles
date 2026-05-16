{
  config,
  pkgs,
  lib,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
  claudeConfigDir = "${homeDir}/.config/claude";
  link = config.lib.file.mkOutOfStoreSymlink;

  settings = {
    permissions = {
      allow = [
        "Bash(git:*)"
        "Bash(nix:*)"
        "Bash(fish:*)"
        "Bash(nvim:*)"
        "Bash(cat:*)"
        "Bash(ls:*)"
        "Bash(find:*)"
        "Bash(grep:*)"
        "Bash(rg:*)"
        "Bash(fd:*)"
        "Bash(bat:*)"
        "Bash(eza:*)"
        "Bash(mkdir:*)"
        "Bash(cp:*)"
        "Bash(mv:*)"
        "Bash(rm:*)"
        "Bash(touch:*)"
        "Bash(echo:*)"
        "Bash(which:*)"
        "Bash(gh:*)"
        "Bash(node:*)"
        "Bash(vite:*)"
        "Bash(bun:*)"
        "Bash(deno:*)"
      ];
      deny = [
        "Bash(sudo:*)"
        "Bash(curl:*)"
        "Bash(wget:*)"
        "Bash(rm -rf /:*)"
      ];
    };
  };
in
{
  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${claudeConfigDir}"
    ${pkgs.jq}/bin/jq -n '${builtins.toJSON settings}' > "${claudeConfigDir}/settings.json"
    chmod 644 "${claudeConfigDir}/settings.json"
  '';

  xdg.configFile = {
    "claude/skills".source = link "${dotfilesDir}/claude/skills";
  };
}
