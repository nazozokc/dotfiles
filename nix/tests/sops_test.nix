# Tests for nix/modules/home-manager/program/sops/default.nix
#
# These tests verify the configuration values added in the PR:
#   - home.file.".config/secrets/.keep" placeholder file
#   - home.sessionVariables: SOPS_AGE_KEY_FILE, GITHUB_TOKEN_PATH,
#                            OPENAI_API_KEY_PATH, ANTHROPIC_API_KEY_PATH
#
# Run with: nix-unit ./nix/tests/sops_test.nix
# Or evaluate statically: nix eval --file ./nix/tests/sops_test.nix

let
  fakeHomeDir = "/home/testuser";

  # Minimal lib stubs – only the functions actually referenced by the module
  # are needed here.  The new additions (home.file and home.sessionVariables)
  # are NOT wrapped in lib.mkIf, so they are unconditionally accessible.
  fakeLib = {
    # mkIf is used only for the pre-existing `sops` block – return a sentinel
    # value so the attribute is still present without triggering evaluation of
    # the sops-nix module system.
    mkIf = _cond: value: value;
    optionalAttrs = cond: attrs: if cond then attrs else { };
  };

  # Minimal pkgs stub – only stdenv.isLinux is consulted by this module.
  fakePkgs = {
    stdenv = {
      isLinux = true;
    };
  };

  # Minimal config stub
  fakeConfig = {
    home.homeDirectory = fakeHomeDir;
  };

  sopsModule = import ../modules/home-manager/program/sops/default.nix {
    config = fakeConfig;
    pkgs = fakePkgs;
    lib = fakeLib;
  };
in
{
  tests = {
    # -----------------------------------------------------------------------
    # home.file ".config/secrets/.keep"  (new in this PR)
    # -----------------------------------------------------------------------

    test_keep_file_attribute_exists = {
      expr = sopsModule.home.file ? ".config/secrets/.keep";
      expected = true;
    };

    test_keep_file_has_text_attribute = {
      expr = sopsModule.home.file.".config/secrets/.keep" ? text;
      expected = true;
    };

    test_keep_file_text_is_empty_string = {
      expr = sopsModule.home.file.".config/secrets/.keep".text;
      expected = "";
    };

    # -----------------------------------------------------------------------
    # home.sessionVariables  (new in this PR)
    # -----------------------------------------------------------------------

    test_sessionVariables_attribute_exists = {
      expr = sopsModule ? home;
      expected = true;
    };

    test_SOPS_AGE_KEY_FILE_exists = {
      expr = sopsModule.home.sessionVariables ? SOPS_AGE_KEY_FILE;
      expected = true;
    };

    test_SOPS_AGE_KEY_FILE_value = {
      expr = sopsModule.home.sessionVariables.SOPS_AGE_KEY_FILE;
      expected = "${fakeHomeDir}/.config/sops/age/keys.txt";
    };

    test_SOPS_AGE_KEY_FILE_uses_homeDir = {
      expr =
        builtins.substring 0 (builtins.stringLength fakeHomeDir)
          sopsModule.home.sessionVariables.SOPS_AGE_KEY_FILE;
      expected = fakeHomeDir;
    };

    test_GITHUB_TOKEN_PATH_exists = {
      expr = sopsModule.home.sessionVariables ? GITHUB_TOKEN_PATH;
      expected = true;
    };

    test_GITHUB_TOKEN_PATH_value = {
      expr = sopsModule.home.sessionVariables.GITHUB_TOKEN_PATH;
      expected = "${fakeHomeDir}/.config/secrets/github_token";
    };

    test_OPENAI_API_KEY_PATH_exists = {
      expr = sopsModule.home.sessionVariables ? OPENAI_API_KEY_PATH;
      expected = true;
    };

    test_OPENAI_API_KEY_PATH_value = {
      expr = sopsModule.home.sessionVariables.OPENAI_API_KEY_PATH;
      expected = "${fakeHomeDir}/.config/secrets/openai_api_key";
    };

    test_ANTHROPIC_API_KEY_PATH_exists = {
      expr = sopsModule.home.sessionVariables ? ANTHROPIC_API_KEY_PATH;
      expected = true;
    };

    test_ANTHROPIC_API_KEY_PATH_value = {
      expr = sopsModule.home.sessionVariables.ANTHROPIC_API_KEY_PATH;
      expected = "${fakeHomeDir}/.config/secrets/anthropic_api_key";
    };

    # -----------------------------------------------------------------------
    # Path suffix checks – variables must reference the secrets directory
    # -----------------------------------------------------------------------

    test_SOPS_AGE_KEY_FILE_ends_with_correct_path = {
      expr =
        let
          v = sopsModule.home.sessionVariables.SOPS_AGE_KEY_FILE;
          suffix = ".config/sops/age/keys.txt";
          len = builtins.stringLength v;
          suffixLen = builtins.stringLength suffix;
        in
        builtins.substring (len - suffixLen) suffixLen v;
      expected = ".config/sops/age/keys.txt";
    };

    test_all_secret_paths_are_under_config_secrets = {
      # Each of the three _PATH variables must contain ".config/secrets/"
      expr =
        let
          vars = sopsModule.home.sessionVariables;
          containsSecretsDir = path: builtins.match ".*\.config/secrets/.*" path != null;
        in
        builtins.all containsSecretsDir [
          vars.GITHUB_TOKEN_PATH
          vars.OPENAI_API_KEY_PATH
          vars.ANTHROPIC_API_KEY_PATH
        ];
      expected = true;
    };

    # -----------------------------------------------------------------------
    # Regression: SOPS age keyFile and sessionVariable must agree
    # -----------------------------------------------------------------------

    test_sops_age_keyFile_matches_SOPS_AGE_KEY_FILE_variable = {
      # The sops.age.keyFile and the session variable should point to the same path
      expr = sopsModule.sops.age.keyFile == sopsModule.home.sessionVariables.SOPS_AGE_KEY_FILE;
      expected = true;
    };
  };
}
