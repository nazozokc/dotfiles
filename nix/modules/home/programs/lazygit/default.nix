{
  pkgs,
  lib,
  config,
  dotfilesDir,
  ...
}:

let
  checkJsonschema = lib.getExe pkgs.check-jsonschema;

  # Pin the schema to the version of lazygit that is actually installed.
  # master drifts, so an unpinned URL makes this check non-reproducible and
  # turns it into a coin flip on every switch.
  schemaUrl = "https://raw.githubusercontent.com/jesseduffield/lazygit/v${pkgs.lazygit.version}/schema/config.json";
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
    enable = lib.mkForce true;
    source = lib.mkForce "${dotfilesDir}/lazygit/config.yml";
  };

  home.activation.validateLazygitSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    SETTINGS_FILE="${lazygitConfigFile}"

    echo "Validating lazygit config.yml against v${pkgs.lazygit.version} schema..."
    # NOTE: do not append `2>&1` here. Inside the `if` condition it swallows
    # check-jsonschema's diagnostics, so an invalid config only ever printed a
    # generic warning and nobody could see which keys were wrong.
    if ${checkJsonschema} --default-filetype yaml --schemafile "${schemaUrl}" "$SETTINGS_FILE"; then
      echo "lazygit config.yml validation passed"
    else
      echo "warning: lazygit config.yml validation failed against v${pkgs.lazygit.version} schema (see errors above)" >&2
    fi
  '';
}
