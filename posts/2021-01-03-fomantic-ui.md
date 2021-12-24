* ブログの見た目を整える
    :PROPERTIES:
    :DATE: [2021-01-03 Sun]
    :TAGS: :hakyll:ブログ:haskell:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
** コードブロックの整形
   :PROPERTIES:
   :CUSTOM_ID: コードブロックの整形
   :END:
今まで、コードブロックは酷い見た目でした。 [[/images/old-codeblock.png]]

現在は以下のように表示されるようになりました！

#+begin_src haskell
  main = do
      putStrLn "Hello world!"
#+end_src

*** やったこと
    :PROPERTIES:
    :CUSTOM_ID: やったこと
    :END:
ここでは、以下のFomantic-UI要素を使用しました。

- Segment
- Attached label

又、各コードブロックに同じ処理をするために、Hakyllの=pandocCompilerWithTransform=を使用しています。
syntaxhilightは[[https://stackoverflow.com/a/43699538][=Hakyll=に合わせて]]=Highlight.js=を使用しています。

**** 最終的なHTML
     :PROPERTIES:
     :CUSTOM_ID: 最終的なhtml
     :END:
#+begin_example
  <div class="ui segment">
      <div class="ui top right attached label"> haskell </div>
      <div class="sourceCode" id="cb1">
          <pre class="sourceCode haskell SourceCode">
              <code class="sourceCode haskell hljs bash">
                  <span id="cb1-1"><a href="#cb1-1" aria-hidden="true"></a>
                      main
                      <span class="ot">=</span>
                      <span class="kw"><span class="hljs-keyword">do</span></span>
                  </span>
                  <span id="cb1-2"><a href="#cb1-2" aria-hidden="true"></a>    
                      <span class="fu">putStrLn</span> 
                      <span class="st"><span class="hljs-string">"Hello world!"</span></span>
                  </span>
              </code>
          </pre>
      </div>
  </div>
#+end_example

**** =pandocCompilerWithTransform=を使用した処理
     :PROPERTIES:
     :CUSTOM_ID: pandoccompilerwithtransformを使用した処理
     :END:
=pandocCompilerWithTransform=は=pandocCompiler=の一種で、Markdownなどを=Pandoc=型に変換しその値をいじることができます。
=Pandoc=型には便利な型クラス=Walkable=があるので、これを使用します。

=Walkable=とは、「値の中を歩き、各子要素を与えられた関数に適用して置き換える」ような処理をします。

- [ ] WIP

**** 右上に拡張子を表示する
     :PROPERTIES:
     :CUSTOM_ID: 右上に拡張子を表示する
     :END:
右上に拡張子を表示するために使われているのが、[[https://fomantic-ui.com/elements/label.html#attached][attached
label]]です。
注意する点として、これは「コードブロックとは別の=div=として使用する」必要があります。

**** 親=Div=に=segment=を設定する
     :PROPERTIES:
     :CUSTOM_ID: 親divにsegmentを設定する
     :END:
=code=ブロックの親の=Div=に、=class="ui segment"=を設定してください。
(他の要素はあっても大丈夫だと思いますが、とにかく[[https://fomantic-ui.com/elements/segment.html][segment]]が必要です。)\\
尚、きちんと調べているわけではないので、他のものでも代用できるのかもしれません。

[[/images/attached-label-wraped-in-segment.png]] /(赤丸は注釈)/

これをしない場合、ひとまわり上の=segment=、どこにもない場合webページの右上にこのラベルが表示されることになります。

[[/images/attached-label-not-wraped-in-segment.png]] /(赤丸は注釈)/

**** テキストの折り返し
     :PROPERTIES:
     :CUSTOM_ID: テキストの折り返し
     :END:
これはシンプルにCSSの=overflow:auto=を使っています。

** 画像の整形
   :PROPERTIES:
   :CUSTOM_ID: 画像の整形
   :END:
これまでは画像が正しいサイズになっておらず、このようになっていました。

#+caption: 昔の画像表示
[[/images/old-image-view.png]]

現在は、この画像のようになっています。

#+caption: 今の画像表示
[[/images/current-image.view.png]]

*** =ui image=
    :PROPERTIES:
    :CUSTOM_ID: ui-image
    :END:
=ui image=を使うことで、親のSegment以内に納めてくれます。\\
又それにプラスして=rounded=をつけることで角を丸めています。
(最終的には=ui rounded image=となりました)

** メニューの作成
   :PROPERTIES:
   :CUSTOM_ID: メニューの作成
   :END:
画面上部にあるメニューを作成しました。
これは主に=ui menu=を使っています。
それに追加して、viewportの上部に固定するために=fixed=を、色を反転させるために=inverted=をつけています。

*** コンテンツの内容がかぶらないようにする
    :PROPERTIES:
    :CUSTOM_ID: コンテンツの内容がかぶらないようにする
    :END:
=fixed=を使った場合、そのままでは下のdiv(このサイトではidとして=content=を持つdiv)の内容に被ってしまいます。

#+caption: 何も対処しない場合
[[/images/fixed-menu-without-margin.png]]

そこで、=content= divに=margin-top: 5em=を適用しています。\\
尚これは、同じ構成をしていた[[https://fomantic-ui.com/collections/menu.html][Fomantic-UIのモバイルページ]]での設定値をそのまま持ってきています。
(モバイル端末で見るか、ブラウザの横幅を狭めれば見えると思います)

#+begin_src css
  #content {
      margin-top: 5em;
  }
#+end_src

*** Feedのリンクを右づめにする
    :PROPERTIES:
    :CUSTOM_ID: feedのリンクを右づめにする
    :END:
=menu=の中にある=item=に、=right=と入れるだけでそこから下の=item=全てが右詰になります。
このサイトだと以下のようになっています。

#+begin_example
  <div id="header" class="ui fixed inverted menu">
      <!-- 省略 -->
      <a href="/feeds/atom/general.xml" class="right item">Atom feed</a>
      <a href="/feeds/rss/general.xml" class="item"><i class="rss icon"></i></a>
  </div>
#+end_example
