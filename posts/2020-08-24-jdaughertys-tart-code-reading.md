* jtdaugherty/tart ソースリーディングメモ
    :PROPERTIES:
    :DATE: [2020-08-24 Mon]
    :TAGS: :tart:cli:haskell:memo:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
AAエディター(?)である[[https://github.com/jtdaugherty/tart][Tart]]の内部実装を読んだ時のメモ

** Eventの処理
   :PROPERTIES:
   :CUSTOM_ID: eventの処理
   :END:
#+begin_example
  main
   |- Events.handleEvent
      |- マウスでの描画イベントを処理
      |- マウスがドラッグ中でかつ前回と違うものの上にある時はここでイベントを終了する
      |- 現在のモードに合わせて、イベントを処理する
        |- Events.Main.handleEvent
          |- Events.Main.handleCommonEvent
          |   |- ツールバー系のトグルをする
          |- Events.Main.handleAttrEvent
          |   |- Attributes(fg,bg,style)がクリックされた場合、変更作業をする
          |- Events.Main.handleEvent
#+end_example
