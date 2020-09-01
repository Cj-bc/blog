---
title: blenderマテリアル のblend modeについて
tags:
  - blender
  - memo
  - material
  - 3dcg
date: August 16, 2020
qiita: false
---

- Blenderのバージョン: 2.80
- 公式のリファレンス: [blender manual -- materials](https://docs.blender.org/manual/en/2.80/render/eevee/materials/settings.html)

Blend modeは、表面の色の計算が終わった後にどのようにカラーバッファに影響するかを決めます。

# Opaque {.small-caption}

アルファチャンネル(=透明度)を完全に無視し、色を上書きします。これが一番早いモードです。

# Additive {.small-caption}

直前の色に表面の色を加算します。アルファ値は、 _neutral color_ の黒 (0.0, 0.0, 0.0, 0.0) と表面の色を混ぜるために使われます。

# Multiplicative {.small-caption}

直前の色と表面の色を乗算します。アルファ値は、 _neutral color_ の白 (1.0, 1.0, 1.0) と表面の色を混ぜるために使われます。

# Alpha Clip {.small-caption}

アルファ値がclip閾値を上回った場合のみ、直前の色は表面の色で上書きされます。

# Alpha Hashed {.small-caption}

アルファ値がランダムで決められたclip閾値を上回った場合のみ、直前の色は表面の色で上書きされます。
この統計学的なアプローチはノイズが多いですが、ソートの問題なしにアルファ値のブレンドを概算できます。レンダー設定でサンプル数を増やすと、最終的なノイズを減らすことができます。


# Alpha Blending {.small-caption}

アルファ値のブレンドを使い、直前の色の上に表面の色をオーバーレイします。

