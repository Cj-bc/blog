---
title: blenderのSmooth
tags:
  - blender
  - memo
  - tips
date: August 17, 2020
qiita: false
---

Blenderには、面と面を補完して滑らかに表示する`shade smooth`という機能があります。
しかし、何も考えずに使おうとすると思わぬところが補完され、予期せぬ結果になることが多々起こります。

![shade flatの結果](https://pbs.twimg.com/media/Efm72cmU8AI3H5K?format=jpg&name=medium)

![shade smoothの結果](https://pbs.twimg.com/media/Efm74u6UcAEU2nM?format=jpg&name=medium)

# Auto Smoothを使おう

Auto Smoothは、面の角度によって`shade smooth`と`shade flat`を使い分けてくれる機能です。
[blender-cg.netさんの記事](https://blender-cg.net/smooth-flat/)で知りました。

[公式リファレンス(英語)](https://docs.blender.org/manual/ja/2.80/modeling/meshes/structure.html#auto-smooth)

これを使うと、かなり快適に使うことができます！わーい！！

![auto smoothの場所](https://pbs.twimg.com/media/Efm8n4uUYAALg-g?format=png&name=small)

![auto smoothを適用してみた結果](https://pbs.twimg.com/media/Efm8pyjU8AAU01a?format=jpg&name=medium)
