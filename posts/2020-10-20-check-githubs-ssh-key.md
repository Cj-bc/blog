---
title: Githubのssh鍵の確認をする
tags:
  - ssh
  - github
kind: memo
date: October 20, 2020
---

# Tl;Dr

基本的にはここに書いてありました

- [公式マニュアル][manual]

---

未読メールを確認していたところ、Githubさんから以下のようなメールが届いていました

> The following SSH key was added to your account:
> 
<key name>
<:区切りの二文字の英数字が並んでいる文字列(`\([[:alnum:]]{2}:\)\+`)(正規表現は自信ない)>
> 
If you believe this key was added in error, you can remove the key and disable
access at the following location:
>
https://github.com/settings/keys


これは、昔確かに自分で追加したはずのSSH鍵なので問題はないはず...ですが念のため確認してみます

# 確認する

私はgpgキーを使ってssh認証をしているため、gpgキーの情報を確認すれば良いはずです。
が、`xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx`なんて文字列を見つけることができない。IPv6でしかみたことないぞ。  
...そんなことなかったです。 **md5のハッシュでした**

## 自分の鍵のmd5ハッシュを確認する

```sh
# ssh-agentが立ち上がっていなければ、以下のコマンドで立ち上げます
$ eval "$(ssh-agent -s)"

$ ssh-add -l -E md5
> <md5ハッシュ>
```

これが一致すれば大丈夫

## Githubの設定画面から確認する

[githubの設定画面のここ](https://github.com/settings/keys)で鍵の一覧を見ることができます。
その中の *New SSH keys* に該当の名前の鍵があるはずです。
そこの鍵名の下に書いてある`SHA256: ...`が確認するべき値です。  
この値について、「GPG fingerprintとも合わん！」「GPG keyidとも合わん！！」「何だこいつ！！！」と暴れていましたが  
安心してください。 *GPGじゃない* です。  
これは、[マニュアル][manual]に書いてあります。

```sh
$ ssh-add -l -E sha256
> <sha256ハッシュ>
```

ここで出てきたハッシュを比較すれば良いです。

[manual]: <https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/reviewing-your-ssh-keys>
