* VRM_IMPORTER_for_BlenderでVRMモデルを作る際の注意点
    :PROPERTIES:
    :DATE: [2020-10-24 Sat]
    :TAGS: :VRM:blender:VRM_IMPORTER_for_Blender:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
** 全てのメッシュの原点(Origin)を /ワールド座標系の/ 原点に置く
   :PROPERTIES:
   :CUSTOM_ID: 全てのメッシュの原点originを-ワールド座標系の-原点に置く
   :END:

#+begin_quote
  There are not an object on the origin (もしくは)
  が原点座標にありません
#+end_quote

というエラーについて。単刀直入にいうと、 全てのメッシュは
*Originをワールド座標系の原点におく必要があります*

これは、 *=Set origin> Origin to Geometry=とは違う*
ので注意してください。

これをするには、

1. 3Dカーソルを原点に移動
2. オブジェクトを選択
3. =Set origin> Origin to 3D cursor=

の手順を踏みます。

** 追加したmeshオブジェクトのtransformは全て0(scaleは1)にする
   :PROPERTIES:
   :CUSTOM_ID: 追加したmeshオブジェクトのtransformは全て0scaleは1にする
   :END:
Blender上では全然問題なく見えますが、これをしておかないとexportした後に変な位置にオブジェクトが表示されてしまいます。
(私は=3tenePRO=で動作確認をしていますが、おそらく他でもそうなると思います。)\\
具体的には、「全てのトランスフォームが0(scaleは1)に指定された通りに表示」されます。

*** 具体例:
    :PROPERTIES:
    :CUSTOM_ID: 具体例
    :END:
scaleが1になっていない例 [[/images/sscale_isnt_1.jpeg]]

scaleが1になるように調整した例 [[/images/scale_is_1.jpeg]]

rotationが0になっていない例 [[/images/rotation_isnt_0.jpeg]]

rotationが0になっている例 [[/images/rotation_is_0.jpeg]]

*** 直し方
    :PROPERTIES:
    :CUSTOM_ID: 直し方
    :END:
Inspectorで各transformの値を確認します。そうしたら、それを覚えておき値は0に修正。
=Edit mode=に移行して、 *originを中心に、軸を指定して先ほど覚えた値分*
回転させます。

*** 最終系
    :PROPERTIES:
    :CUSTOM_ID: 最終系
    :END:
綺麗になりました！！

#+caption: 全部直した
[[/images/completed.jpg]]

** Shade Textureは必ず設定する
   :PROPERTIES:
   :CUSTOM_ID: shade-textureは必ず設定する
   :END:
ShadeTextureを設定していないと、面を法線と反対側から見たときにピンク色になってしまいます。
これは、=Shade Color=が塗られているからで、それを防ぎ表面と同じものを表示したい場合は必ず設定する必要があります。
なお、=MainTexture=と同じテクスチャで問題ないと思います。

設定してなかった:\\

#+begin_html
  <blockquote class="twitter-tweet" data-conversation="none" data-theme="dark">
#+end_html

#+begin_html
  <p lang="ja" dir="ltr">
#+end_html

色々と調節は必要そうだね pic.twitter.com/ndXTzYKdfQ

#+begin_html
  </p>
#+end_html

--- mi'e himari (@mihe_himari) October 26, 2020

#+begin_html
  </blockquote>
#+end_html

#+begin_html
  <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
#+end_html

設定した:\\

#+begin_html
  <blockquote class="twitter-tweet" data-conversation="none" data-theme="dark">
#+end_html

#+begin_html
  <p lang="ja" dir="ltr">
#+end_html

他のオブジェクトにも設定してきた...ﾖｼ!! pic.twitter.com/8tMJyUaawt

#+begin_html
  </p>
#+end_html

--- mi'e himari (@mihe_himari) October 26, 2020

#+begin_html
  </blockquote>
#+end_html

#+begin_html
  <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
#+end_html

** todo
   :PROPERTIES:
   :CUSTOM_ID: todo
   :END:

- [ ] 画像入れる
- [ ] 動画いれる
