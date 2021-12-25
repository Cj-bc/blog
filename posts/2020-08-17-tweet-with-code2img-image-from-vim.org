* twtyとcode2imgでコードの画像つきツイートをする
    :PROPERTIES:
    :DATE: [2020-08-18 Tue]
    :TAGS: :twitter:tool:memo:cli:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
[[https://github.com/skanehira/code2img][skanehira/code2img]]を使うとコードを手軽に画像化できます。\\
そして、[[https://github.com/skanehira/code2img.vim][skanehira/code2img.vim]]を使うとvimから簡単にクリップボードに生成できます。\\
これ、すごく便利です。\\
しかし、この画像つきのツイートをしたいなと思った時、このままではtwitter.comを開いて投稿しなければなりません。\\
vimmerとして、すごく、困る。

ということで困っていたら、[[https://twitter.com/gorilla0513][gorilla]]さん自身も同じことを思っていたようで、爆速で作ってくれました。

#+begin_html
  <script src="https://gist.github.com/skanehira/7dd6ed0dc8da8c6e87a11ab70ea83b53.js"></script>
#+end_html

[[https://github.com/skanehira/code2img][skanehira/code2img]]と、[[https://github.com/mattn/twty][mattn/twty]]があれば動きます。

すごい。使いやすい。実際に使ってみた結果:

#+begin_html
  <blockquote class="twitter-tweet">
#+end_html

#+begin_html
  <p lang="ja" dir="ltr">
#+end_html

ツイートのテストだよ。中身は適当なコードだよ。
pic.twitter.com/QGJ2Y9iLfz

#+begin_html
  </p>
#+end_html

--- Cj-bc_sd.sh🐟🔯🌸🐾@ソーダー (@Cj_bc_sd) August 17, 2020

#+begin_html
  </blockquote>
#+end_html

#+begin_html
  <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
#+end_html

とても良い。ありがとうgorillaさん。
