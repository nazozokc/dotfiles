# nix/flake-parts/pi-check.nix
# pi 拡張の静的検証 (tsc) と実ローダーでの登録・描画チェック。
# flake check と `nix run .#pi-check` の両方から同じ derivation を使う。
_: {
  perSystem =
    { pkgs, ... }:
    let
      piRoot = ../modules/home/programs/pi;
      checkRoot = piRoot + "/check";
      extensions = piRoot + "/extensions";
      piPkg = pkgs.pi-coding-agent or null;

      nodeModules =
        if piPkg == null then
          null
        else
          pkgs.runCommand "pi-check-node-modules" { } ''
            mkdir -p $out/node_modules/@earendil-works $out/node_modules/@types
            ln -s ${piPkg}/lib/node_modules/pi-monorepo \
              $out/node_modules/@earendil-works/pi-coding-agent
            ln -s ${piPkg}/lib/node_modules/pi-monorepo/node_modules/@earendil-works/pi-tui \
              $out/node_modules/@earendil-works/pi-tui
            ln -s ${piPkg}/lib/node_modules/pi-monorepo/node_modules/@earendil-works/pi-ai \
              $out/node_modules/@earendil-works/pi-ai
            ln -s ${piPkg}/lib/node_modules/pi-monorepo/node_modules/typebox \
              $out/node_modules/typebox
            ln -s ${piPkg}/lib/node_modules/pi-monorepo/node_modules/@types/node \
              $out/node_modules/@types/node
          '';

      piCheck =
        if nodeModules == null then
          pkgs.runCommand "pi-check-skipped" { } ''
            mkdir -p $out/bin
            cat > $out/bin/pi-check <<'EOF'
            #!/bin/sh
            echo "pi-check: skipped (pi-coding-agent unavailable on this platform)"
            EOF
            chmod +x $out/bin/pi-check
          ''
        else
          pkgs.runCommand "pi-check" { } ''
            mkdir -p $out/bin extensions
            cp -r ${nodeModules}/node_modules ./node_modules
            cp -r ${extensions}/. ./extensions/
            cp ${checkRoot}/package.json \
              ${checkRoot}/tsconfig.json \
              ${checkRoot}/load-test.ts \
              ${checkRoot}/render-test.ts \
              ./

            echo "pi-check: tsc" >&2
            ${pkgs.typescript_5}/bin/tsc -p tsconfig.json --pretty false
            echo "pi-check: load extensions" >&2
            ${pkgs.nodejs_latest}/bin/node load-test.ts
            echo "pi-check: render surfaces" >&2
            ${pkgs.nodejs_latest}/bin/node render-test.ts

            cat > $out/bin/pi-check <<'EOF'
            #!/bin/sh
            echo "pi-check: passed (tsc + 6 extensions + 9 render surfaces)"
            EOF
            chmod +x $out/bin/pi-check
          '';
    in
    {
      checks.pi-check = piCheck;
      apps.pi-check = {
        type = "app";
        meta.description = "pi 拡張の型・登録・描画を検証する";
        program = "${piCheck}/bin/pi-check";
      };
    };
}
