---
title: Prismの使い方メモ
keywords:
  - Haskell
  - Prism
date: August 07, 2020
---

# この記事について

## わかること

- なぜ`Setter`は`Prism`なのか
- `set`や`over`等と組み合わせて使えるよ

## わからないこと

- `Prism`の学術的・数学的な意味や定義
- 具体的な使い方、応用の仕方

しっかりとした解説は[debugIto's diaryさんの記事](https://debug-ito.hatenablog.com/entry/20150112/1421028231)がわかりやすかったです。

# Tl;Dr

- 型変換していくと`Setter`が`Prism`だとわかるよ
- `Prism`なら`Setter`というわけ**ではない**
- ただし`Prism`なら`ASetter`だよ
- `set`や`over`等と組み合わせて使えるよ

---

# Prismとは

[Prism](https://hackage.haskell.org/package/lens-4.19.2/docs/Control-Lens-Combinators.html#t:Prism)は、[Lens](https://hackage.haskell.org/package/lens)パッケージに含まれる型です。
大雑把な説明としては、列挙型もしくは直和型の各値コンストラクタのLens、みたいなもの...?
よく言われるのは「全体から部分を取り出せる」「部分から全体を作れる」ということです。
前者は「Either(全体)の中のLeftの値だけ、Rightの値だけ取り出せる(それぞれ`_Left`, `_Right`)」「Leftの値を渡してあげるとLeftの値が作れる」

# 使い方

まずはPrismを用意したい型を用意します。
そして`makePrisms`{haskell}を使うと自作型の`Prism`{haskell}を作成できます。

```haskell
data Example = Foo Int Bool
             | Bar String (Maybe Int)
             | Baz Int
              deriving Show

makePrisms ''Example
```

その後、`set`や`over`と合わせることでSetterとして使うことができます。
また、`^?`を使うと値を取得することができます。
尚、複数のフィールドを持つ場合は**全てを含んだタプル**を中身として取ります

```haskell
>:t _Foo
_Foo
  :: (profunctors-5.3:Data.Profunctor.Choice.Choice p,
      Applicative f) =>
     p (Int, Bool) (f (Int, Bool)) -> p Example (f Example)

>:t set _Foo
set _Foo :: (Int, Bool) -> Example -> Example
>:t over _Foo
over _Foo :: ((Int, Bool) -> (Int, Bool)) -> Example -> Example

>set _Foo (10, True) (Foo 0 False)
Foo 10 True
>set _Foo (10, True) (Baz 10)
Baz 10

>over _Foo (over _1 (*2)) (Foo 10 True)
Foo 20 True
>over _Foo (over _1 (*2)) (Baz 10)
Baz 10

>(Foo 10 True)^?_Foo
Just (10,True)
>Baz 10^?_Foo
Nothing
```


# 身近なPrism: Setter

実は、`Setter`はPrismです。

## SetterがPrismであることの説明(?)

型を追ってみます

```haskell
type Setter s t a b = forall (f :: * -> *). Settable f => (a -> f b) -> s -> f t
type Prism s t a b  = forall (p :: * -> * -> *) (f :: * -> *). (Choice p, Applicative f) => p a (f b) -> p s (f t)
```

ここで、

- `(->)`{haskell}の`Choice`{haskell}のインスタンスがある
- `Settable`{haskell}は全て`Applicative`{haskell}のインスタンスを持つ

```haskell
:i Choice
class Profunctor p => Choice (p :: * -> * -> *) where
    ...
        -- Defined in ‘profunctors-5.3:Data.Profunctor.Choice’
instance [safe] Choice (->)
  -- Defined in ‘profunctors-5.3:Data.Profunctor.Choice’

:i Settable
class (Applicative f,
       distributive-0.6.1:Data.Distributive.Distributive f,
       Traversable f) =>
      Settable (f :: * -> *) where
  ...
  -- Defined in ‘Control.Lens.Internal.Setter’
```

ので、`Setter`は全て`Prism`になります。

### `Prism`{haskell}の`p`を`(->)`に具体化すると


```haskell
type Prism s t a b = forall (p :: * -> * -> *) (f :: * -> *). (Choice p, Applicative f) => p a (f b) -> p s (f t)

-- (->)は'Choice'のインスタンスを持つので
                     forall (f :: * -> *). Applicative f => (->) a (f b) -> (->) s (f t)
                   = forall (f :: * -> *). Applicative f => (a -> f b) -> s -> f t


```


# Prismがoverやsetで使える理由

上述の通り、`Setter`が`Prism`であることはわかりましたが、その逆は成り立ちません(`Settable f => Applicative f`ではないため)。
しかし、`over`や`set`は`ASetter`を引数としてとるので使うことができます。


```haskell
set  :: ASetter s t a b -> b -> s -> t
over :: ASetter s t a b -> (a -> b) -> s -> t

type Setter  s t a b = forall (f :: * -> *). Settable f => (a -> f b)        -> s -> f t
type ASetter s t a b =                                     (a -> Identity b) -> s -> Identity t

```

`ASetter`は、`Setter`に含まれる`f`を`Identity`に固定した型です。
そのため、`Setter`を与えるとその中の`f`は`Identity`に推論されます。
`Identity`は`Applicative`なので、`Prism`を受け取ることが可能になります。

```haskell
                                                    Prism s t a b = ASetter s t a b
forall (f :: * -> *). Applicative f => (a -> (f b)) -> s -> (f t) = (a -> Identity b) -> s -> Identity t
                             (a -> Identity b) -> s -> Identity t = (a -> Identity b) -> s -> Identity t
```



