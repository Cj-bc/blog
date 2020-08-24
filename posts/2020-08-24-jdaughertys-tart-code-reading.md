---
title: jtdaugherty/tart ソースリーディングメモ
keywords:
  - tart
  - cli
  - haskell
  - memo
kind: Memo
date: August 24, 2020
updated: August 24, 2020
---

AAエディター(?)である[Tart](https://github.com/jtdaugherty/tart)の内部実装を読んだ時のメモ

# Eventの処理

```
main
 |- Events.handleEvent
    |- マウスでの描画イベントを処理
    |- マウスがドラッグ中でかつ前回と違うものの上にある時はここでイベントを終了する
    |- 現在のモードに合わせて、イベントを処理する
      |- Events.Main.handleEvent
        |- Events.Main.handleCommonEvent
        |   |- ツールバー系のトグルをする
        |- Events.Main.handleAttrEvent
        |   |- Attributes(fg,bg,style)がクリックされた場合、変更作業をする
        |- Events.Main.handleEvent
```
