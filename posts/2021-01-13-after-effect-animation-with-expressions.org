* Expressionを使ったアニメーションのメモ
    :PROPERTIES:
    :DATE: [2021-01-13 Wed]
    :TAGS: :after effect:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
** Expression制御のEffectは必ずリネームする
   :PROPERTIES:
   :CUSTOM_ID: expression制御のeffectは必ずリネームする
   :END:
同じ種類のExpression制御Effectを一度しか使わないなら問題にはならない気がしますが、
後々見やすいのでリネームをした方が良いです。\\
そして、*できる限り早く*リネームするようにしてください。
複数の同じエフェクトを作成・Expressionから参照した後にリネームした場合、
*Expression内の同名の部分が全て新しい名前に置き換わります*。\\
例えば、

*** リネームの仕方
    :PROPERTIES:
    :CUSTOM_ID: リネームの仕方
    :END:
[[https://creativecow.net/forums/thread/rename-expression-controlsae-2/][参考にしたもの]]

例えばスライダー制御のEffectをリネームする場合、=エフェクト→スライダー制御=を選択してEnterを押します。
すると普段通りにリネームできます。+私は気付かなかった...+

** Expressionのコピペ
   :PROPERTIES:
   :CUSTOM_ID: expressionのコピペ
   :END:
作成したExpressionを含むプロパティを選択しC-cで普段通りコピー。
コピー先のレイヤーを選択してC-vするとそのままペーストされる。

** 一定の時間から色などを変化させる
   :PROPERTIES:
   :CUSTOM_ID: 一定の時間から色などを変化させる
   :END:
固定値を使わなくても=Marker=を使えばできる。

- [[https://helpx.adobe.com/jp/after-effects/user-guide.html/jp/after-effects/using/layer-markers-composition-markers.ug.html][公式URL]]
- [[https://cj-bc.github.com/blog/posts/2021-01-19-after-effect-markers.html][Markerについて]]

*** レイヤーマーカーを参照する
    :PROPERTIES:
    :CUSTOM_ID: レイヤーマーカーを参照する
    :END:
https://helpx.adobe.com/jp/after-effects/user-guide.html/jp/after-effects/using/expression-language-reference.ug.html

#+begin_example
  thisLayer.marker.key(n: int)    // n番目のマーカーを参照する
  thisLayer.marker.key(name: str) // nameという名前のマーカーを参照する
  thisLayer.marker.nearestKey(t: float) // tという時間に一番近いマーカーを参照する
#+end_example
