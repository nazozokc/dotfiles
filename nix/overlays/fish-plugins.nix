# nix/overlays/fish-plugins.nix
final: prev:
let
  buildFishPlugin = prev.fishPlugins.buildFishPlugin;

  fisher = buildFishPlugin {
    pname = "fisher";
    version = "4.4.8";
    src = prev.fetchFromGitHub {
      owner = "jorgebucaran";
      repo = "fisher";
      rev = "a04308be92daa6cfecdbb0ca58b1e8508664cff2";
      hash = "sha256-Sf671UGOQXtOMrqoEOIBG5TCt0p5fd+aKGF2ExImbbs=";
    };
    meta = {
      description = "A plugin manager for fish";
      homepage = "https://github.com/jorgebucaran/fisher";
      license = prev.lib.licenses.mit;
      maintainers = with prev.lib.maintainers; [ ];
    };
  };

  # fishna - repository not found on GitHub (ryoppippi/fishna returns 404)
  # Uncomment and fix when the correct repository is available:
  # fishna = buildFishPlugin {
  #   pname = "fishna";
  #   version = "0.0.0-unstable";
  #   src = prev.fetchFromGitHub {
  #     owner = "ryoppippi";
  #     repo = "fishna";
  #     rev = "main";
  #     sha256 = "sha256-lN8rC2q8qGzKN5R+qJ4JtQ4jL4pQ4J4jL4pQ4J4jL4pQ4=";
  #   };
  #   meta = {
  #     description = "A fish shell prompt theme";
  #     homepage = "https://github.com/ryoppippi/fishna";
  #     license = prev.lib.licenses.mit;
  #     maintainers = with prev.lib.maintainers; [ ];
  #   };
  # };
in
{
  fishPlugins = {
    fisher = fisher;
    # fishna = fishna;
  };
  inherit fisher;
}
