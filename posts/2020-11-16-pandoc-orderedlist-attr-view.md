---
title: pandocのorderedListのAttributeと見た目について
tags:
  - pandoc
  - haskell
kind: memo
date: November 16, 2020
---

[公式リファレンス](https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html#t:Block)
を見てもよくわからないので、markdownに変換して試してみた。

# 実際のコード

## ListNumberStyle

[ListNumberStyle](https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html#t:ListNumberStyle)は、
数字表現(1,2,3なのかi,ii,iiiなのかなど)を決めるもの。
わかりやすいように他の内容は一致させています。

``` haskell
[OrderedList (1,DefaultStyle,TwoParens) [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1, Example,TwoParens)     [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,Decimal,TwoParens)      [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,LowerRoman,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,UpperRoman,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,LowerAlpha,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,UpperAlpha,TwoParens)   [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
]
```

これをvimで開き、`%!pandoc -f native -t markdown`で試した。これ便利なのでおすすめ。
その結果が以下:

``` {.markdown .result}
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
```

`Default`/`Example`はどうやらDecimalになってしまう模様。あとは大体名前の通りになった。

## ListNumberDelim

[ListNumberDelim](https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html#t:ListNumberDelim)
は、数字の後につくやつ。  
コードは基本先ほどと同じものを使用




``` haskell
[OrderedList (1,DefaultStyle,DefaultDelim) [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,DefaultStyle,Period)       [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,DefaultStyle,OneParen)     [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
,OrderedList (1,DefaultStyle,TwoParens)    [[Plain [Str "hoge"]],[Plain [Str "foo"]]]
]
```

結果が以下。

``` {.markdown .result}
1.  hoge
2.  foo

1.  hoge
2.  foo

1)  hoge
2)  foo

(1) hoge
(2) foo
```
