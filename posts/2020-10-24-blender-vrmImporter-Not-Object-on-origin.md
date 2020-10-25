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
![scaleが1じゃない](/src/sscale_isnt_1.jpeg)

scaleが1になるように調整した例
![scaleが1](/src/scale_is_1.jpeg)

rotationが0になっていない例
![rotationが0じゃない](/src/rotation_isnt_0.jpeg)

rotationが0になっている例
![rotationが0](/src/rotation_is_0.jpeg)


## 直し方

Inspectorで各transformの値を確認します。そうしたら、それを覚えておき値は0に修正。
`Edit mode`に移行して、 **originを中心に、軸を指定して先ほど覚えた値分** 回転させます。

## 最終系

綺麗になりました！！

![全部直した](/src/completed.jpg)

# todo

- [ ] 画像入れる
- [ ] 動画いれる
