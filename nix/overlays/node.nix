# nix/overlays/node.nix

final: prev: {

  nodejs = prev.nodejs_22;

  pnpm = prev.pnpm.override {
    nodejs = final.nodejs;
  };

}

