# Test suite entry point – aggregates all per-module test files.
#
# Run all tests with:
#   nix-unit ./nix/tests/default.nix
#
# Or run individual suites:
#   nix-unit ./nix/tests/direnv_test.nix
#   nix-unit ./nix/tests/sops_test.nix
#   nix-unit ./nix/tests/flake_modules_test.nix

let
  direnv = import ./direnv_test.nix;
  sops = import ./sops_test.nix;
  flakeModules = import ./flake_modules_test.nix;

  # nix-unit expects a flat `tests` attrset at the top level.
  # Merge all test suites with a namespace prefix so test names are unique.
  prefixAttrs =
    prefix: attrs:
    builtins.listToAttrs (
      map (name: {
        name = "${prefix}_${name}";
        value = attrs.${name};
      }) (builtins.attrNames attrs)
    );
in
{
  tests =
    (prefixAttrs "direnv" direnv.tests)
    // (prefixAttrs "sops" sops.tests)
    // (prefixAttrs "flake_modules" flakeModules.tests);
}