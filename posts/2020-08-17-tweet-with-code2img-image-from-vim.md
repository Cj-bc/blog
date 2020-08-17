---
title: twtyとcode2imgでコードの画像つきツイートをする
keywords:
  - twitter
  - tool
  - memo
  - cli
date: August 18, 2020
---

[skanehira/code2img](https://github.com/skanehira/code2img)を使うとコードを手軽に画像化でき、
[skanehira/code2img.vim](https://github.com/skanehira/code2img.vim)を使うとvimから簡単にクリップボードに生成できるのですが、
この画像つきのツイートをしたいなと思った時、このままではtwitter.comを開いて投稿しなければなりません。  
vimmerとして、すごく、困る。  

ということで困っていたら、[gorilla](https://twitter.com/gorilla0513)さん自身も同じことを思っていたようで、爆速で作ってくれました。

<script src="https://gist.github.com/skanehira/7dd6ed0dc8da8c6e87a11ab70ea83b53.js"></script>


[skanehira/code2img](https://github.com/skanehira/code2img)と、[mattn/twty](https://github.com/mattn/twty)があれば動きます。

すごい。使いやすい。実際に使ってみた結果:

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">ツイートのテストだよ。中身は適当なコードだよ。 <a href="https://t.co/QGJ2Y9iLfz">pic.twitter.com/QGJ2Y9iLfz</a></p>&mdash; Cj-bc_sd.sh🐟🔯🌸🐾@ソーダー (@Cj_bc_sd) <a href="https://twitter.com/Cj_bc_sd/status/1295377990524657665?ref_src=twsrc%5Etfw">August 17, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

とても良い。ありがとうgorillaさん。
