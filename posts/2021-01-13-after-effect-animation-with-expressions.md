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
