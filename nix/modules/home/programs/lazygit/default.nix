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
  home.file."${config.xdg.configHome}/lazygit/config.yml".source =
    "${dotfilesDir}/lazygit/config.yml";

  home.activation.validateLazygitSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_FILE="${lazygitConfigFile}"

    echo "Validating lazygit config.yml..."
    if ${checkJsonschema} --default-filetype yaml --schemafile "${schemaUrl}" "$SETTINGS_FILE" 2>&1; then
      echo "lazygit config.yml validation passed"
    else
      echo "warning: lazygit config.yml validation failed (schema may be outdated)" >&2
    fi
  '';
}
