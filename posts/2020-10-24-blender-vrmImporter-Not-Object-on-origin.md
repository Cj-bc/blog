---
title: VRM_IMPORTER_for_BlenderでVRMモデルを作る際の注意点
tags:
  - VRM
  - blender
  - VRM_IMPORTER_for_Blender
kind: memo
date: October 24, 2020
---

# 全てのメッシュの原点(Origin)を *ワールド座標系の* 原点に置く

> There are not an object on the origin <mesh名>
(もしくは)
  <mesh名> が原点座標にありません

というエラーについて。単刀直入にいうと、
全てのメッシュは **Originをワールド座標系の原点におく必要があります**

これは、 **`Set origin> Origin to Geometry`とは違う** ので注意してください。

これをするには、

1. 3Dカーソルを原点に移動
2. オブジェクトを選択
3. `Set origin> Origin to 3D cursor`

の手順を踏みます。

# 追加したmeshオブジェクトのtransformは全て0(scaleは1)にする

Blender上では全然問題なく見えますが、これをしておかないとexportした後に変な位置にオブジェクトが表示されてしまいます。
(私は`3tenePRO`で動作確認をしていますが、おそらく他でもそうなると思います。)  
具体的には、「全てのトランスフォームが0(scaleは1)に指定された通りに表示」されます。

## 具体例:

scaleが1になっていない例
![scaleが1じゃない](/images/sscale_isnt_1.jpeg)

scaleが1になるように調整した例
![scaleが1](/images/scale_is_1.jpeg)

rotationが0になっていない例
![rotationが0じゃない](/images/rotation_isnt_0.jpeg)

rotationが0になっている例
![rotationが0](/images/rotation_is_0.jpeg)


## 直し方

Inspectorで各transformの値を確認します。そうしたら、それを覚えておき値は0に修正。
`Edit mode`に移行して、 **originを中心に、軸を指定して先ほど覚えた値分** 回転させます。

## 最終系

綺麗になりました！！

![全部直した](/images/completed.jpg)

# Shade Textureは必ず設定する

ShadeTextureを設定していないと、面を法線と反対側から見たときにピンク色になってしまいます。
これは、`Shade Color`が塗られているからで、それを防ぎ表面と同じものを表示したい場合は必ず設定する必要があります。
なお、`MainTexture`と同じテクスチャで問題ないと思います。

設定してなかった:  
<blockquote class="twitter-tweet" data-conversation="none" data-theme="dark"><p lang="ja" dir="ltr">色々と調節は必要そうだね <a href="https://t.co/ndXTzYKdfQ">pic.twitter.com/ndXTzYKdfQ</a></p>&mdash; mi&#39;e himari (@mihe_himari) <a href="https://twitter.com/mihe_himari/status/1320608433352003584?ref_src=twsrc%5Etfw">October 26, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

設定した:  
<blockquote class="twitter-tweet" data-conversation="none" data-theme="dark"><p lang="ja" dir="ltr">他のオブジェクトにも設定してきた...ﾖｼ!! <a href="https://t.co/8tMJyUaawt">pic.twitter.com/8tMJyUaawt</a></p>&mdash; mi&#39;e himari (@mihe_himari) <a href="https://twitter.com/mihe_himari/status/1320613366864330752?ref_src=twsrc%5Etfw">October 26, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

# todo

- [ ] 画像入れる
- [ ] 動画いれる
