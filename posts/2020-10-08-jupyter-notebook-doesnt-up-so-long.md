* jupyter notebookがうまく起動しなかった
    :PROPERTIES:
    :DATE: [2020-10-10 Sat]
    :TAGS: :python:jupyter:macOS:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
#+begin_example
  $ jupyter notebook
#+end_example

だと、鯖は立ち上がるもののページが読み込めずうまくいかなかった。
試しに、[[https://qiita.com/ciela/items/0e0392f600c92b93d7c6][この記事]]に従ってみたところ接続できた。
よくわからないけど、まぁ動いたのでよし。別段VM環境でもなかったんだけどなぁ

#+begin_example
  $ jupyter notebook --ip=\*
#+end_example
