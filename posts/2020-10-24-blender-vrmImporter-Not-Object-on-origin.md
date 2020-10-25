---
title: VRM_IMPORTER_for_Blender -- there are not an object on the origin
tags:
  - VRM
  - blender
  - VRM_IMPORTER_for_Blender
kind: memo
date: October 24, 2020
---

> There are not an object on the origin <mesh名>
(もしくは)
  <mesh名> が原点座標にありません

というエラーについて。単刀直入にいうと、
全てのメッシュは **Originをワールド座標系の原点におく必要がある**

これは、 **`Set origin> Origin to Geometry`とは違う** ので注意

これをするには、

1. 3Dカーソルを原点に移動
2. オブジェクトを選択
3. `Set origin> Origin to 3D cursor`

の手順を踏む。



# todo

- [ ] 画像入れる
- [ ] 動画いれる
