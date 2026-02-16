{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule {
  pname = "gh-brag";
  version = "unstable-2024-01-01";

  src = fetchFromGitHub {
    owner = "jackchuka";
    repo = "gh-brag";
    rev = "fdabde7f31efc5acdefcf037f55e414785e28960";
    sha256 = lib.fakeSha256;
  };

  vendorHash = lib.fakeSha256;

  meta = with lib; {
    description = "GitHub CLI extension to show brag stats";
    license = licenses.mit;
    mainProgram = "gh-brag";
  };
}

