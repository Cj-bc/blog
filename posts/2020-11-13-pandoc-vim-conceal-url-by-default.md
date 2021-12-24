* vim-pandoc-syntaxでurlを非表示にしたい
    :PROPERTIES:
    :DATE: [2020-11-13 Fri]
    :TAGS: :vim:pandoc:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
** vimwikiのハイライトが欲しい
   :PROPERTIES:
   :CUSTOM_ID: vimwikiのハイライトが欲しい
   :END:
** markdown/vimwiki/pandocのsyntaxハイライト
   :PROPERTIES:
   :CUSTOM_ID: markdownvimwikipandocのsyntaxハイライト
   :END:
vimwikiのsyntaxでは、以下のようなリンクは

#+begin_example
  [説明](url)
#+end_example

このように表示されます(=+conceal=オプションが有効な場合)

[[file:url][説明]]

これがあると、長いURLを持つドキュメントでの可読性がグンと上がります

例えば、[[https://cj-bc.github.io/blog/posts/2020-08-19-blender-data-blocks.html][blender
data blocks]]の記事は=markdown=/=vimwiki=/=pandoc=それぞれのsyntaxで
以下のように見えます。

#+caption: markdown, vimwiki, pandocのハイライトの違い
[[/images/difference_md-vimwiki-pandoc.png]]

さて、これを普段使いの=pandoc=syntaxでも使いたいというのが今回の希望です。

** 結論: デフォルトの変数を設定しろ
   :PROPERTIES:
   :CUSTOM_ID: 結論-デフォルトの変数を設定しろ
   :END:
もうこれが答えでした！\\
ドキュメントよもうね！！！！

#+begin_example
  let g:pandoc#syntax#conceal#urls = 1
#+end_example

これだけでURLの=conceal=が有効になり、vimwikiと同じような見た目になります

#+caption: 設定後のpandoc
[[/images/pandoc-with-conceal.png]]

** おまけ
   :PROPERTIES:
   :CUSTOM_ID: おまけ
   :END:
ちなみに該当のコードは[[https://github.com/vim-pandoc/vim-pandoc-syntax/blob/2521e2e9b99a3550e1a20f24e09fa46679cbbbc7/syntax/pandoc.vim#L300-L304][300-304行目]]にありました。

#+begin_example
  if g:pandoc#syntax#conceal#urls == 1
      syn region pandocReferenceURL matchgroup=pandocOperator start=/\]\@1<=(/ end=/)/ keepend conceal
  else
      syn region pandocReferenceURL matchgroup=pandocOperator start=/\]\@1<=(/ end=/)/ keepend
  endif
#+end_example
