---
title: vim-pandoc-syntaxでurlを非表示にしたい
tags:
  - vim
  - pandoc
kind: memo
date: November 13, 2020
---

# vimwikiのハイライトが欲しい

# markdown/vimwiki/pandocのsyntaxハイライト

vimwikiのsyntaxでは、以下のようなリンクは

```markdown
[説明](url)
```

このように表示されます(`+conceal`オプションが有効な場合)

[説明](url)

これがあると、長いURLを持つドキュメントでの可読性がグンと上がります

例えば、[blender data blocks](https://cj-bc.github.io/blog/posts/2020-08-19-blender-data-blocks.html)の記事は`markdown`/`vimwiki`/`pandoc`それぞれのsyntaxで
以下のように見えます。

![markdown, vimwiki, pandocのハイライトの違い](/images/difference_md-vimwiki-pandoc.png)

さて、これを普段使いの`pandoc`syntaxでも使いたいというのが今回の希望です。

# 結論: デフォルトの変数を設定しろ

もうこれが答えでした！  
ドキュメントよもうね！！！！

```vim
let g:pandoc#syntax#conceal#urls = 1
```

これだけでURLの`conceal`が有効になり、vimwikiと同じような見た目になります

![設定後のpandoc](/images/pandoc-with-conceal.png)

# おまけ

ちなみに該当のコードは[300-304行目](https://github.com/vim-pandoc/vim-pandoc-syntax/blob/2521e2e9b99a3550e1a20f24e09fa46679cbbbc7/syntax/pandoc.vim#L300-L304)にありました。

``` vim
if g:pandoc#syntax#conceal#urls == 1
    syn region pandocReferenceURL matchgroup=pandocOperator start=/\]\@1<=(/ end=/)/ keepend conceal
else
    syn region pandocReferenceURL matchgroup=pandocOperator start=/\]\@1<=(/ end=/)/ keepend
endif
```
