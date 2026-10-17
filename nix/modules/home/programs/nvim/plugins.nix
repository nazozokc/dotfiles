{ pkgs, lib }:
let
  buildVimPluginFromLock = { owner, repo, rev, sha256 ? lib.fakeSha256 }:
    pkgs.vimUtils.buildVimPlugin {
      pname = repo;
      version = builtins.substring 0 7 rev;
      src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; };
    };

  known = with pkgs.vimPlugins; [
  ];

  fromLock = map (p: buildVimPluginFromLock {
    owner = p.owner;
    repo  = p.repo;
    rev   = p.rev;
    sha256 = p.sha256 or lib.fakeSha256;
  }) [
    { owner = "vinnymeller"; repo = "swagger-preview.nvim"; rev = "42999dd6ad0bbb3e6ca5e857f3fc3c12de014110"; sha256 = lib.fakeSha256; }
  ];
in
known ++ fromLock
