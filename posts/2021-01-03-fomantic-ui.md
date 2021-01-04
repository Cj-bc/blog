---
title: ブログの見た目を整える
author: Cj-bc
tags:
  - hakyll
  - ブログ
  - haskell
date: Jan 03, 2021
---
# コードブロックの整形
今まで、コードブロックは酷い見た目でした。
![前までのコードブロック](/images/old-codeblock.png)

現在は以下のように表示されるようになりました！

``` haskell
main = do
    putStrLn "Hello world!"
```

## やったこと

ここでは、以下のFomantic-UI要素を使用しました。

- Segment
- Attached label

又、各コードブロックに同じ処理をするために、Hakyllの`pandocCompilerWithTransform`を使用しています。
syntaxhilightは[`Hakyll`に合わせて](https://stackoverflow.com/a/43699538)`Highlight.js`を使用しています。

### 最終的なHTML

```html
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
```

### `pandocCompilerWithTransform`を使用した処理

`pandocCompilerWithTransform`は`pandocCompiler`の一種で、Markdownなどを`Pandoc`型に変換しその値をいじることができます。
`Pandoc`型には便利な型クラス`Walkable`があるので、これを使用します。

`Walkable`とは、「値の中を歩き、各子要素を与えられた関数に適用して置き換える」ような処理をします。

- [ ] WIP

### 右上に拡張子を表示する

右上に拡張子を表示するために使われているのが、[attached label](https://fomantic-ui.com/elements/label.html#attached)です。
注意する点として、これは「コードブロックとは別の`div`として使用する」必要があります。

### 親`Div`に`segment`を設定する

`code`ブロックの親の`Div`に、`class="ui segment"`を設定してください。
(他の要素はあっても大丈夫だと思いますが、とにかく[segment](https://fomantic-ui.com/elements/segment.html)が必要です。)  
尚、きちんと調べているわけではないので、他のものでも代用できるのかもしれません。

![segmentがある場合](/images/attached-label-wraped-in-segment.png)
*(赤丸は注釈)*

これをしない場合、ひとまわり上の`segment`、どこにもない場合webページの右上にこのラベルが表示されることになります。

![segmentがない場合](/images/attached-label-not-wraped-in-segment.png)
*(赤丸は注釈)*

### テキストの折り返し

これはシンプルにCSSの`overflow:auto`を使っています。


# 画像の整形

これまでは画像が正しいサイズになっておらず、このようになっていました。

![昔の画像表示](/images/old-image-view.png)

現在は、この画像のようになっています。

![今の画像表示](/images/current-image.view.png)

## `ui image`

`ui image`を使うことで、親のSegment以内に納めてくれます。  
又それにプラスして`rounded`をつけることで角を丸めています。
(最終的には`ui rounded image`となりました)


# メニューの作成

画面上部にあるメニューを作成しました。
これは主に`ui menu`を使っています。
それに追加して、viewportの上部に固定するために`fixed`を、色を反転させるために`inverted`をつけています。

## コンテンツの内容がかぶらないようにする

`fixed`を使った場合、そのままでは下のdiv(このサイトではidとして`content`を持つdiv)の内容に被ってしまいます。

![何も対処しない場合](/images/fixed-menu-without-margin.png)

そこで、`content` divに`margin-top: 5em`を適用しています。  
尚これは、同じ構成をしていた[Fomantic-UIのモバイルページ](https://fomantic-ui.com/collections/menu.html)での設定値をそのまま持ってきています。
(モバイル端末で見るか、ブラウザの横幅を狭めれば見えると思います)

```css
#content {
    margin-top: 5em;
}
```

## Feedのリンクを右づめにする

`menu`の中にある`item`に、`right`と入れるだけでそこから下の`item`全てが右詰になります。
このサイトだと以下のようになっています。

```html
<div id="header" class="ui fixed inverted menu">
    <!-- 省略 -->
    <a href="/feeds/atom/general.xml" class="right item">Atom feed</a>
    <a href="/feeds/rss/general.xml" class="item"><i class="rss icon"></i></a>
</div>
```
