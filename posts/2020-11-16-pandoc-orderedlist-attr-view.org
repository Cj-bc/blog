* pandocのBlock
    :PROPERTIES:
    :DATE: [2020-11-16 Mon]
    :TAGS: :pandoc:haskell:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
[[https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html#t:Block][hackage]]と[[https://pandoc.org/MANUAL.html][pandoc
manual]] を見てもよくわからないので、markdownに変換して試してみた。

** OrderedList
   :PROPERTIES:
   :CUSTOM_ID: orderedlist
   :END:
*** ListNumberStyle
    :PROPERTIES:
    :CUSTOM_ID: listnumberstyle
    :END:
[[https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html#t:ListNumberStyle][ListNumberStyle]]は、
数字表現(1,2,3なのかi,ii,iiiなのかなど)を決めるもの。
わかりやすいように他の内容は一致させています。

#+begin_src haskell
  [OrderedList (1,DefaultStyle,TwoParens) [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1, Example,TwoParens)     [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,Decimal,TwoParens)      [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,LowerRoman,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,UpperRoman,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,LowerAlpha,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,UpperAlpha,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ]
#+end_src

これをvimで開き、=%!pandoc -f native -t markdown=で試した。これ便利なのでおすすめ。
その結果が以下:

#+begin_example
  (1) hoge
  (2) foo

  (1) hoge
  (2) foo

  (1) hoge
  (2) foo

  (i) hoge
  (ii) foo

  (I) hoge
  (II) foo

  (a) hoge
  (b) foo

  (A) hoge
  (B) foo
#+end_example

=Default=/=Example=はどうやらDecimalになってしまう模様。あとは大体名前の通りになった。

*** ListNumberDelim
    :PROPERTIES:
    :CUSTOM_ID: listnumberdelim
    :END:
[[https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html#t:ListNumberDelim][ListNumberDelim]]
は、数字の後につくやつ。\\
コードは基本先ほどと同じものを使用

#+begin_src haskell
  [OrderedList (1,DefaultStyle,DefaultDelim) [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,DefaultStyle,Period)       [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,DefaultStyle,OneParen)     [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ,OrderedList (1,DefaultStyle,TwoParens)    [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
  ]
#+end_src

結果が以下。

#+begin_example
  1.  hoge
  2.  foo

  1.  hoge
  2.  foo

  1)  hoge
  2)  foo

  (1) hoge
  (2) foo
#+end_example

** DefinitionList
   :PROPERTIES:
   :CUSTOM_ID: definitionlist
   :END:
[[][DefinitionList]]

#+begin_src haskell
  [DefinitionList
   [([Str "term"],
     [[Plain [Str "One",Space,Str "definition",Space,Str "here"]]
     ,[Plain [Str "Second?",SoftBreak,Str ":"], Plain [Str"Second", Space,Str "line",Space,Str "of",Space, Str "definition"]]
     ]
   )]
  ]
#+end_src

#+begin_example
  term
  :   One definition here
  :   Second? :
  :   Maybe second, maybe third
#+end_example
