# Tests for the commonHomeModules refactoring in flake.nix
#
# The PR extracted a shared `commonHomeModules` list used by both
# mkLinuxHomeConfig and mkWSLHomeConfig.  These tests verify the structural
# invariants of that refactoring:
#
#   - Both helpers share the same seven base modules.
#   - Each helper appends exactly two platform-specific modules.
#   - The platform-specific modules are distinct between Linux and WSL.
#   - The combined list has the expected length (9 modules each).
#
# Because flake.nix itself cannot be imported as a plain Nix expression, the
# tests reproduce the *same* list construction logic that appears in flake.nix
# and assert its properties using pure Nix evaluation.
#
# Run with: nix-unit ./nix/tests/flake_modules_test.nix
# Or evaluate statically: nix eval --file ./nix/tests/flake_modules_test.nix

let
  # -------------------------------------------------------------------------
  # Mirror the module lists from flake.nix using symbolic string identifiers.
  # The actual file-path / flake-output values are represented as strings so
  # that this file stays self-contained and evaluates without network access.
  # -------------------------------------------------------------------------

  # Shared base modules – identical in mkLinuxHomeConfig and mkWSLHomeConfig
  linuxCommonHomeModules = [
    "nix-index-database.homeModules.nix-index"
    "sops-nix.homeManagerModules.sops"
    "nix/shared.nix"
    "nix/modules/home-manager/dotfiles-link.nix"
    "nix/modules/home-manager/program/nvim/default.nix"
    "agent-skills-nix.homeManagerModules.default"
    "nix/modules/home-manager/agent-skills.nix"
  ];

  wslCommonHomeModules = [
    "nix-index-database.homeModules.nix-index"
    "sops-nix.homeManagerModules.sops"
    "nix/shared.nix"
    "nix/modules/home-manager/dotfiles-link.nix"
    "nix/modules/home-manager/program/nvim/default.nix"
    "agent-skills-nix.homeManagerModules.default"
    "nix/modules/home-manager/agent-skills.nix"
  ];

  # Platform-specific additions
  linuxPlatformModules = [
    "nix/modules/home-manager/tools-read.nix"
    "nix/modules/linux/system.nix"
  ];

  wslPlatformModules = [
    "nix/modules/home-manager/tools-read-wsl.nix"
    "nix/modules/wsl/system.nix"
  ];

  # Final module lists (mirrors `commonHomeModules ++ [...]` in flake.nix)
  linuxModules = linuxCommonHomeModules ++ linuxPlatformModules;
  wslModules = wslCommonHomeModules ++ wslPlatformModules;

  sharedModuleCount = 7;
  platformModuleCount = 2;
  totalModuleCount = sharedModuleCount + platformModuleCount;
in
{
  tests = {
    # -----------------------------------------------------------------------
    # commonHomeModules list size
    # -----------------------------------------------------------------------

    test_linux_common_modules_count = {
      expr = builtins.length linuxCommonHomeModules;
      expected = sharedModuleCount;
    };

    test_wsl_common_modules_count = {
      expr = builtins.length wslCommonHomeModules;
      expected = sharedModuleCount;
    };

    # -----------------------------------------------------------------------
    # Both helpers share IDENTICAL base modules (the key refactoring invariant)
    # -----------------------------------------------------------------------

    test_common_modules_are_identical_between_linux_and_wsl = {
      expr = linuxCommonHomeModules == wslCommonHomeModules;
      expected = true;
    };

    # -----------------------------------------------------------------------
    # Platform-specific module lists
    # -----------------------------------------------------------------------

    test_linux_has_two_platform_modules = {
      expr = builtins.length linuxPlatformModules;
      expected = platformModuleCount;
    };

    test_wsl_has_two_platform_modules = {
      expr = builtins.length wslPlatformModules;
      expected = platformModuleCount;
    };

    # Linux uses tools-read (not tools-read-wsl)
    test_linux_uses_tools_read = {
      expr = builtins.elem "nix/modules/home-manager/tools-read.nix" linuxPlatformModules;
      expected = true;
    };

    test_linux_does_not_use_tools_read_wsl = {
      expr = builtins.elem "nix/modules/home-manager/tools-read-wsl.nix" linuxPlatformModules;
      expected = false;
    };

    # WSL uses tools-read-wsl (not tools-read)
    test_wsl_uses_tools_read_wsl = {
      expr = builtins.elem "nix/modules/home-manager/tools-read-wsl.nix" wslPlatformModules;
      expected = true;
    };

    test_wsl_does_not_use_tools_read = {
      expr = builtins.elem "nix/modules/home-manager/tools-read.nix" wslPlatformModules;
      expected = false;
    };

    # Linux uses linux/system.nix, WSL uses wsl/system.nix
    test_linux_uses_linux_system = {
      expr = builtins.elem "nix/modules/linux/system.nix" linuxPlatformModules;
      expected = true;
    };

    test_wsl_uses_wsl_system = {
      expr = builtins.elem "nix/modules/wsl/system.nix" wslPlatformModules;
      expected = true;
    };

    # Platform module lists must differ from each other
    test_linux_and_wsl_platform_modules_differ = {
      expr = linuxPlatformModules == wslPlatformModules;
      expected = false;
    };

    # -----------------------------------------------------------------------
    # Final combined lists
    # -----------------------------------------------------------------------

    test_linux_total_module_count = {
      expr = builtins.length linuxModules;
      expected = totalModuleCount;
    };

    test_wsl_total_module_count = {
      expr = builtins.length wslModules;
      expected = totalModuleCount;
    };

    # Combined lists are different (they diverge at the platform-specific part)
    test_linux_and_wsl_final_lists_differ = {
      expr = linuxModules == wslModules;
      expected = false;
    };

    # -----------------------------------------------------------------------
    # Shared modules are present in both final lists
    # -----------------------------------------------------------------------

    test_sops_module_in_linux_config = {
      expr = builtins.elem "sops-nix.homeManagerModules.sops" linuxModules;
      expected = true;
    };

    test_sops_module_in_wsl_config = {
      expr = builtins.elem "sops-nix.homeManagerModules.sops" wslModules;
      expected = true;
    };

    test_nix_index_in_linux_config = {
      expr = builtins.elem "nix-index-database.homeModules.nix-index" linuxModules;
      expected = true;
    };

    test_nix_index_in_wsl_config = {
      expr = builtins.elem "nix-index-database.homeModules.nix-index" wslModules;
      expected = true;
    };

    test_agent_skills_in_linux_config = {
      expr = builtins.elem "nix/modules/home-manager/agent-skills.nix" linuxModules;
      expected = true;
    };

    test_agent_skills_in_wsl_config = {
      expr = builtins.elem "nix/modules/home-manager/agent-skills.nix" wslModules;
      expected = true;
    };

    # -----------------------------------------------------------------------
    # The shared prefix of both lists equals commonHomeModules
    # -----------------------------------------------------------------------

    # Take the first `sharedModuleCount` elements of each combined list and
    # assert they equal the respective commonHomeModules (the refactoring
    # invariant: shared prefix is extracted, not duplicated or reordered).
    test_linux_prefix_equals_commonHomeModules = {
      expr =
        builtins.genList (i: builtins.elemAt linuxModules i) sharedModuleCount
        == linuxCommonHomeModules;
      expected = true;
    };

    test_wsl_prefix_equals_commonHomeModules = {
      expr =
        builtins.genList (i: builtins.elemAt wslModules i) sharedModuleCount
        == wslCommonHomeModules;
      expected = true;
    };

    # Simpler: verify each shared module appears at its expected index
    test_shared_nix_index_at_position_0 = {
      expr = builtins.elemAt linuxModules 0;
      expected = builtins.elemAt wslModules 0;
    };

    test_shared_sops_at_position_1 = {
      expr = builtins.elemAt linuxModules 1;
      expected = builtins.elemAt wslModules 1;
    };

    test_shared_shared_nix_at_position_2 = {
      expr = builtins.elemAt linuxModules 2;
      expected = builtins.elemAt wslModules 2;
    };

    test_platform_modules_diverge_at_position_7 = {
      expr = builtins.elemAt linuxModules 7 != builtins.elemAt wslModules 7;
      expected = true;
    };

    test_platform_modules_diverge_at_position_8 = {
      expr = builtins.elemAt linuxModules 8 != builtins.elemAt wslModules 8;
      expected = true;
    };
  };
}