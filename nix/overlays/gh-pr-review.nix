final: prev: {
  gh-pr-review = prev.buildGoModule {
    pname = "gh-pr-review";
    version = "0.1.0";

    src = prev.fetchFromGitHub {
      owner = "yukikotani231";
      repo = "gh-pr-review";
      rev = "v0.1.0";
      hash = "sha256-b2liYeyutBmdg/lTwhFcuhGXHOa7HWquihh/nONbzAM=";
    };

    postPatch = ''
      substituteInPlace go.mod --replace "go 1.26.0" "go 1.24"
      sed -i '/^toolchain/d' go.mod
    '';

    overrideModAttrs = (
      _: {
        postPatch = ''
          substituteInPlace go.mod --replace "go 1.26.0" "go 1.24"
          sed -i '/^toolchain/d' go.mod
        '';
      }
    );

    vendorHash = "sha256-k9OksW+WVZqaYdFNPe9LLSKzDSp0mECR/X1qJeVSJvQ=";
    # proxyVendor は削除

    meta = with prev.lib; {
      description = "TUI PR reviewer for GitHub";
      homepage = "https://github.com/yukikotani231/gh-pr-review";
      license = licenses.mit;
      mainProgram = "gh-pr-review";
    };
  };
}
