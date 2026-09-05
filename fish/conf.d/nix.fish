# Nix のプロファイルを PATH に追加する
# fish は /etc/profile を source しないため、Nix 関係の PATH は
# ここで明示的に追加する必要がある。
# fish_add_path は存在しないパス・既に PATH にあるパスを自動でスキップする。
# 最後に呼んだパスが最も優先される。

switch (uname)
    case Darwin
        # nix-darwin のシステムプロファイル
        fish_add_path /run/current-system/sw/bin
        # nix profile / Determinate installer のユーザープロファイル
        fish_add_path ~/.nix-profile/bin
        # nix-darwin 統合 home-manager の per-user プロファイル
        fish_add_path /etc/profiles/per-user/(id -un)/bin
    case Linux
        # multi-user インストールのデフォルトプロファイル (nix 本体)
        fish_add_path /nix/var/nix/profiles/default/bin
        # home-manager / ユーザープロファイル
        fish_add_path ~/.nix-profile/bin
end