{
  pkgs,
  lib,
  config,
  dotfilesDir,
  ...
}:

let
  checkJsonschema = lib.getExe pkgs.check-jsonschema;

  schemaUrl = "https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json";
  lazygitConfigFile = "${config.xdg.configHome}/lazygit/config.yml";
in
{
  programs.lazygit = {
    enable = true;

    # Configuration is in lazygit/config.yml (shared across platforms)
    # settings = {};
  };

  # Deploy shared lazygit config
  # NOTE: home-manager's built-in programs.lazygit also declares this same
  # home.file entry. When settings = {} (empty), it sets enable = false,
  # which would prevent linkGeneration from creating the file unless we
  # explicitly re-enable it here.
  home.file."${config.xdg.configHome}/lazygit/config.yml" = {
    enable = true;
    forceParentDirs = true;
    source = "${dotfilesDir}/lazygit/config.yml";
  };

  home.activation.validateLazygitSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    SETTINGS_FILE="${lazygitConfigFile}"

    echo "Validating lazygit config.yml..."
    if ${checkJsonschema} --default-filetype yaml --schemafile "${schemaUrl}" "$SETTINGS_FILE" 2>&1; then
      echo "lazygit config.yml validation passed"
    else
      echo "warning: lazygit config.yml validation failed (schema may be outdated)" >&2
    fi
  '';
}
