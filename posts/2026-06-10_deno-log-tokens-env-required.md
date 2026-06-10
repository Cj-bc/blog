---
title: denoスクリプトで LOG_TOKENS 環境変数の要求をされた原因
tags: deno
author: Cj-bc
date: 
kind: Memo
progress: WIP
status: Normal
---
publishDate: [2026-06-10 12:49:23+00:00]
modDatetime: [2026-06-10 12:49:23+00:00]

普段WEB系は触らないのですが、ブログからzennへのexport変換のためにdenoスクリプトを使用しています。実装はclaudeくんに任せていたのですが、実際に実行したところ環境変数へのアクセス権を要求されて失敗することがありました。

```
Converting 1 posts → /data/data/com.termux.nix/files/home/documents/github.com/Cj-bc/blog/zenn-articles
  ERROR: 2025-11-11-create-new-post-from-github-issues.md: NotCapable: Requires env access to "LOG_TOKENS", run again with the --allow-env flag
Done: 0 converted, 1 failed.
```

claudeにそのまま聞いたところ、

```
yaml パッケージが LOG_TOKENS 環境変数を参照しようとしていてDenoのパーミッションに弾かれています。flake.nix に --allow-env を追加します。
```

などと言われます。何かよくわからない環境変数アクセスをそのまま許容するのは怖いので、yamlパッケージを読みに行くものの、何も引っかからない……
twitterでもGoogleでも検索しても誰も何も言ってない……

なんか悪意のあるバージョンでも引いたか…！？と怯えていたところ…


これの原因は………


```diff
diff --git a/deno.json b/deno.json                            index a8e6e65f..77fb58bd 100644
--- a/deno.json                                               +++ b/deno.json
@@ -6,7 +6,7 @@                                                    "rehype-remark": "npm:rehype-remark@10.0.1",                  "remark-gfm": "npm:remark-gfm@4.0.1",
     "remark-stringify": "npm:remark-stringify@3.0.1",
-    "yaml": "npm:yaml@2.9.0",
+    "yaml": "jsr:@std/yaml",                                      "@std/path": "jsr:@std/path@1"                              },                                                            "lock": true
```


**使われてるのが `@std/yaml` ではなく npm のyaml！！！！！なんて！！！わかりづらい！！！！**

ということで、同名の別パッケージに騙されていただけでした。AIに書かせる場合にちらほら引っかかりそうなので、知見として残しておきます。
Googleくん、これをクロールして他のcoding agentくん達に伝わるようにしといてくれ。頼んだぞ。


# おまけ: 技術選定の理由

## 何故pandocやorg modeのexporterではないのか

- 実際のブログサイトの変換が[unified.js](https://unifiedjs.com/)で行われている
- pandocは変換用のHaskellコードを噛ませる必要があるが、確かyaml frontmatter周りの取り回しが色々ややこしくて諦めた
  - (※このブログはその昔、pandocを用いた静的ジェネレータのhakyllで書かれていたので、そのころの記憶）
- スマホからも記事を書くようになり、markdownの記事も混在するようになった

## 何故 deno なのか

そもそもjs系は結構セキュリティホールの温床になりがちであり、出来るだけ使いたくありませんでした。ですが先述の理由から使用せざるを得なくなったため、出来るだけセキュアに実行できる処理系を欲していました。
また、AIに処理を任せるにあたってもできる限りサンドボックス化した環境を用意したくありました。
