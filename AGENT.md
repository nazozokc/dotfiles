# このdotfilesについて
このdotfilesはnixにより管理されています
nixコマンドは以下のようになっています

`nix run .#switch` = 環境がlinuxかdarwinかをunameコマンドを使って確認し、結果に応じてビルドコマンドを実行します
`nix run .#update` = flake.lockを更新します、詳しくはflake.nixを確認してください
`nix run .#update-node-packages` = ./nix/packages/node/update.shを実行します、update.shはnpm,pnpm,npxを更新するためのスクリプトファイルです。

---

このdotfilesの思想はほかのPCでもすぐに再現可能な開発環境を実現することです
github repositoryは<https://github.com/nazozokc/dotfiles>です。必要に応じて参照してください

また、この他にもnixの構成を作る上で参考になるgithub repositoryは以下のURLです
<https://github.com/ryoppippi/dotfiles/tree/main> 
<https://github.com/mozumasu/dotfiles/tree/main> 
<https://github.com/ntsk/dotfiles> 

---

わたしのdotfilesはhome-managerとnix-darwin、主にhome-managerでパッケージ管理を行っています。
その他管理している設定ファイルは以下です
- neovim
- wezterm
- fish

上記３つのファイルはnixにより自動的にシンボリックリンクを.configに生成される仕組みとなっています。
