* blenderマテリアル のblend modeについて
    :PROPERTIES:
    :DATE: [2020-08-16 Sun]
    :TAGS: :blender:memo:material:3dcg:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
- Blenderのバージョン: 2.80
- 公式のリファレンス:
  [[https://docs.blender.org/manual/en/2.80/render/eevee/materials/settings.html][blender
  manual -- materials]]

Blend
modeは、表面の色の計算が終わった後にどのようにカラーバッファに影響するかを決めます。

** Opaque
   :PROPERTIES:
   :CUSTOM_ID: opaque
   :CLASS: small-caption
   :END:
アルファチャンネル(=透明度)を完全に無視し、色を上書きします。これが一番早いモードです。

** Additive
   :PROPERTIES:
   :CUSTOM_ID: additive
   :CLASS: small-caption
   :END:
直前の色に表面の色を加算します。アルファ値は、 /neutral color/ の黒
(0.0, 0.0, 0.0, 0.0) と表面の色を混ぜるために使われます。

** Multiplicative
   :PROPERTIES:
   :CUSTOM_ID: multiplicative
   :CLASS: small-caption
   :END:
直前の色と表面の色を乗算します。アルファ値は、 /neutral color/ の白
(1.0, 1.0, 1.0) と表面の色を混ぜるために使われます。

** Alpha Clip
   :PROPERTIES:
   :CUSTOM_ID: alpha-clip
   :CLASS: small-caption
   :END:
アルファ値がclip閾値を上回った場合のみ、直前の色は表面の色で上書きされます。

** Alpha Hashed
   :PROPERTIES:
   :CUSTOM_ID: alpha-hashed
   :CLASS: small-caption
   :END:
アルファ値がランダムで決められたclip閾値を上回った場合のみ、直前の色は表面の色で上書きされます。
この統計学的なアプローチはノイズが多いですが、ソートの問題なしにアルファ値のブレンドを概算できます。レンダー設定でサンプル数を増やすと、最終的なノイズを減らすことができます。

** Alpha Blending
   :PROPERTIES:
   :CUSTOM_ID: alpha-blending
   :CLASS: small-caption
   :END:
アルファ値のブレンドを使い、直前の色の上に表面の色をオーバーレイします。
