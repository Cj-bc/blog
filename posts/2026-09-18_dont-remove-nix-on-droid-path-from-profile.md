---
title: nix-on-droid-path を吹き飛ばしたらあかんかった
tags: nix,nix-on-droid
author: Cj-bc
publishDate: [2026-09-18 00:46:54+00:00]
modDatetime: [2026-09-18 00:46:54+00:00]
kind: Memo
progress: WIP
status: Normal
---

やらかしました。 nix-on-droid環境でnix-on-droid-pathのパッケージが衝突したよと言われ、書いてあったとおり素直にprofileを消したところnixやnix-on-droidすらパスから外れて動かせなくなりました。 ~~少し考えたらわかるだろうに…~~

```sh
$ nix profile remove /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path
removing 'nix-on-droid-path'
removing 'nix-on-droid-path'
$ nix profile list
fish: Unknown command: nix
$ nix-on-droid switch --flake ~/.config/nix-on-droid
fish: Unknown command: nix-on-droid
```
## Tl;Dr

nix storeにあるnixを直接使ってprofileをinstallし直したらいけたっぽいです。

```sh
$ /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path/bin/nix profile install /nix/store/knqm15zfc5gn44n4w49zbkmmd59nkcha-nix-on-droid-path
```

tmux上で扱ってて履歴を辿りやすかったのが不幸中の幸い。tmuxじゃなくてもいいけどターミナルマルチプレクサ、使おう。（ちなみに私はWin環境だとherdrを使っています）

# ことのキッカケ

普通にnix-on-droid.nixを編集した後、switchしようとしたら `[` が衝突すると言われ、switch出来ませんでした。

```sh
$ nix-on-droid switch --flake ~/.config/nix-on-droid
Building activation package...
Executing activation script...
Activating linkBinSh
Activating linkUsrBinEnv
Activating installLogin
Activating installLoginInner
Activating installPackages
nix profile remove
warning: Use 'nix profile list' to see the current profile.
error: An existing package already provides the following file:

         /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path/bin/[

       This is the conflicting file from the new package:

         /nix/store/knqm15zfc5gn44n4w49zbkmmd59nkcha-nix-on-droid-path/bin/[

       To remove the existing package:

         nix profile remove /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path

       The new package can also be installed next to the existing one by assigning a different priority.
       The conflicting packages have a priority of 5.
       To prioritise the new package:

         nix profile install /nix/store/knqm15zfc5gn44n4w49zbkmmd59nkcha-nix-on-droid-path --priority 4

       To prioritise the existing package:

         nix profile install /nix/store/knqm15zfc5gn44n4w49zbkmmd59nkcha-nix-on-droid-path --priority 6
```

hm...とりあえずChatGPTに丸投げしてみると、出力通りremoveしてみろと言われました。

> 原因は、古い世代の nix-on-droid-path がユーザープロファイルに残り、新しい世代と同じコマンド群を提供して衝突していることです。
> まず、ログに表示された古いパッケージだけを削除します。
> 
> > nix profile remove /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path
> 
> その後、--flake には flake.nix ではなく、それを含むディレクトリを指定して再実行してください。

そこで何も考えず一旦削除したところ、nixコマンドすらパスから消えて詰み……となったわけです。
（ちなみに、 priority をいじる方に関しては「問題を隠蔽してるだけなので良くない」という意見を言われ、まぁそれはたしかにそう…と思ったのも判断に影響しています）

# 復旧する

先ほども書いた通り、ログに出力されていたパスを使って `nix profile install` すれば（多分）復旧しました。

```sh
$ /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path/bin/nix profile install /nix/store/knqm15zfc5gn44n4w49zbkmmd59nkcha-nix-on-droid-path
```

以下は試してだめだったものたち:

nix-on-droid switchを直で叩いてもだめ

```

$ /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path/bin/nix-on-droid switch --flake ~/.config/nix-on-droid
Building activation package...
Executing activation script...
Activating linkBinSh
Activating linkUsrBinEnv
Activating installLogin
Activating installLoginInner
Activating installPackages
nix profile remove
warning: Use 'nix profile list' to see the current profile.
$ nix profile list
fish: Unknown command: nix
```

Rollbackもダメ


```sh
$ /nix/store/ki2a2sk3hr87nm9spv0d6nfq6w4036r8-nix-on-droid-path/bin/nix-on-droid rollback --flake ~/.config/nix-on-droid
Executing activation script...
Activating linkBinSh
Activating linkUsrBinEnv
Activating installLogin
Activating installLoginInner
Activating installPackages
nix profile remove
warning: Use 'nix profile list' to see the current profile.
$ nix profile list
fish: Unknown command: nix
```
