---
title: Expressionを使ったアニメーションのメモ
tags:
  - after effect
kind: note
date: January 13, 2021
---

# Expression制御のEffectは必ずリネームする


同じ種類のExpression制御Effectを一度しか使わないなら問題にはならない気がしますが、
後々見やすいのでリネームをした方が良いです。  
そして、**できる限り早く**リネームするようにしてください。
複数の同じエフェクトを作成・Expressionから参照した後にリネームした場合、
**Expression内の同名の部分が全て新しい名前に置き換わります**。  
例えば、

## リネームの仕方
[参考にしたもの](https://creativecow.net/forums/thread/rename-expression-controlsae-2/)  

例えばスライダー制御のEffectをリネームする場合、`エフェクト→スライダー制御`を選択してEnterを押します。
すると普段通りにリネームできます。~~私は気付かなかった...~~

# Expressionのコピペ

作成したExpressionを含むプロパティを選択しC-cで普段通りコピー。
コピー先のレイヤーを選択してC-vするとそのままペーストされる。

# 一定の時間から色などを変化させる

固定値を使わなくても`Marker`を使えばできる。

- [公式URL](https://helpx.adobe.com/jp/after-effects/user-guide.html/jp/after-effects/using/layer-markers-composition-markers.ug.html)
- [Markerについて](https://cj-bc.github.com/blog/posts/2021-01-19-after-effect-markers.html)

## レイヤーマーカーを参照する

https://helpx.adobe.com/jp/after-effects/user-guide.html/jp/after-effects/using/expression-language-reference.ug.html

``` javascript
thisLayer.marker.key(n: int)    // n番目のマーカーを参照する
thisLayer.marker.key(name: str) // nameという名前のマーカーを参照する
thisLayer.marker.nearestKey(t: float) // tという時間に一番近いマーカーを参照する
```
