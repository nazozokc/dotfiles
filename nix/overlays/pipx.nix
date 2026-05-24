final: prev: {
  pipx = prev.pipx.overrideAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [
      # Tests fail due to strict PEP 508 @ URL format checking in pipx 1.8.0
      "test_fix_package_name"
      "test_parse_specifier_for_metadata"
    ];
  });
}
