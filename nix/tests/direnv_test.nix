# Tests for nix/modules/home-manager/program/direnv.nix
#
# These tests verify the configuration values added in the PR:
#   - enableBashIntegration, enableFishIntegration, enableZshIntegration
#   - config.global.disable_stdin
#   - home.file.".config/direnv/direnvrc" content
#
# Run with: nix-unit ./nix/tests/direnv_test.nix
# Or evaluate statically: nix eval --file ./nix/tests/direnv_test.nix

let
  # Minimal fake pkgs – the direnv module only uses pkgs as a pass-through arg
  fakePkgs = { };

  # Import the module as a plain function and call it with minimal args.
  # The module signature is `{ pkgs, ... }:`, so we pass an attrset that
  # satisfies it.  The result is the raw Home-Manager option attrset.
  direnvModule = import ../modules/home-manager/program/direnv.nix { pkgs = fakePkgs; };

  inherit (direnvModule) programs;
  direnvCfg = programs.direnv;

  direnvrc = direnvModule.home.file.".config/direnv/direnvrc";
in
{
  tests = {
    # -----------------------------------------------------------------------
    # Shell integration flags (new in this PR)
    # -----------------------------------------------------------------------

    test_enableBashIntegration_is_true = {
      expr = direnvCfg.enableBashIntegration;
      expected = true;
    };

    test_enableFishIntegration_is_true = {
      expr = direnvCfg.enableFishIntegration;
      expected = true;
    };

    test_enableZshIntegration_is_true = {
      expr = direnvCfg.enableZshIntegration;
      expected = true;
    };

    # -----------------------------------------------------------------------
    # disable_stdin in global config (new in this PR)
    # -----------------------------------------------------------------------

    test_disable_stdin_is_true = {
      expr = direnvCfg.config.global.disable_stdin;
      expected = true;
    };

    # Pre-existing config values must remain unchanged
    test_existing_load_dotenv_is_true = {
      expr = direnvCfg.config.global.load_dotenv;
      expected = true;
    };

    test_existing_strict_env_is_false = {
      expr = direnvCfg.config.global.strict_env;
      expected = false;
    };

    test_existing_warn_timeout = {
      expr = direnvCfg.config.global.warn_timeout;
      expected = "5m";
    };

    # -----------------------------------------------------------------------
    # direnvrc file (new in this PR)
    # -----------------------------------------------------------------------

    test_direnvrc_file_attribute_exists = {
      expr = direnvrc ? text;
      expected = true;
    };

    # builtins.match uses POSIX ERE where `.` does not match newlines, so for
    # multiline content we use builtins.split: if the needle is present the
    # split produces more than one element.
    test_direnvrc_contains_source_up_if_exists = {
      expr = builtins.length (builtins.split "source_up_if_exists" direnvrc.text) > 1;
      expected = true;
    };

    test_direnvrc_contains_dotenvrc_argument = {
      expr = builtins.length (builtins.split "\\.envrc" direnvrc.text) > 1;
      expected = true;
    };

    test_direnvrc_contains_flake_nix_check = {
      expr = builtins.length (builtins.split "flake\\.nix" direnvrc.text) > 1;
      expected = true;
    };

    test_direnvrc_contains_use_flake = {
      expr = builtins.length (builtins.split "use flake" direnvrc.text) > 1;
      expected = true;
    };

    # Negative: direnvrc should NOT call `use nix` (the non-flake fallback is
    # in stdlib only, not in direnvrc – so global direnvrc stays flake-first)
    test_direnvrc_does_not_call_use_nix = {
      # Split on "use nix" – a list of length 1 means the string was NOT found
      expr = builtins.length (builtins.split "use nix" direnvrc.text) == 1;
      expected = true;
    };

    # -----------------------------------------------------------------------
    # Pre-existing core settings must still be present
    # -----------------------------------------------------------------------

    test_direnv_is_enabled = {
      expr = direnvCfg.enable;
      expected = true;
    };

    test_nix_direnv_is_enabled = {
      expr = direnvCfg.nix-direnv.enable;
      expected = true;
    };

    test_silent_mode_is_enabled = {
      expr = direnvCfg.silent;
      expected = true;
    };
  };
}