---
title: Github ActionsでGithub Pagesのリリースを自動化する
keywords:
  - github actions
  - github pages
  - hakyll
  - ブログ
  - 自動化
date: August 07, 2020
---

[このブログ](https://cj-bc.github.io/blog)の生成をGithub Actionsで行えるようにしたので、その時のメモ
尚、現在のworkflowファイルは[Cj-bc/blog -- .github/workflows/publish.yaml](https://github.com/Cj-bc/blog/blob/source/.github/workflows/publish.yaml)にあります。

# 前提

- 静的サイトジェネレーターはHakyll
- ほぼ[チュートリアル](https://jaspervdj.be/hakyll/tutorials/github-pages-tutorial.html)通りの作りになっている
  - `master`の代わりに`publish`、`develop`の代わりに`source`にしてある
- Github Pageでホスティング

# workflowファイルを作成する

## トリガーの設定

自分の環境では、`source`ブランチの中身を使ってビルド→`publish`ブランチにおいて公開、という手順を追っているので、`source`ブランチにpushされたときだけ走るようにします

```yaml
on:
  push:
    branches: [source]
```

## Jobの作成

Jobを作成します。環境はstackが動けばどこでも問題がないので、ubuntuにします。

```yaml
jobs:
  runPublish:
    name: run publish
    runs-on: ubuntu-latest
```


## ステップの作成

ここからstepを作っていきます。

### 必要なブランチをcheckoutする

今回、トリガー対象のブランチ`source`の他に`publish`ブランチを使っています。
しかし、デフォルトではローカルに`publish`ブランチは存在しません。
なので、`actions/checkout`に、全てのブランチとタグの履歴をfetchする`fetch-depth: 0`を付け足す必要があります。

```yaml
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
```

### キャッシュの設定をする

ビルドはなかなかに重い(現在の構成で約4,50分くらい)ので、なるべくキャッシュを活用します。
キャッシュには`actions/cache@v2`を使用します。キャッシュしたいものを生成するactionの前に実行し、キャッシュがあればそこをスキップするようにします。
キャッシュ対象は`~/.stack`ディレクトリです。
これは、[ncaqさんの記事][ncaq -- HaskellプログラムをGitHub Actionsでビルドしてクロスプラットフォーム向けにバイナリをReleaseにアップロードする]から大体を引用させていただきました。

```yaml
      - name: Cache stack
        uses: actions/cache@v2
        with:
          path: ~/.stack
          key: stack-${{ hashFiles('**/stack.yaml.lock') }}-${{ hashFiles('**/package.yaml') }}
          restore-keys: |
            ${{ runner.os }}-stack-${{ hashFiles('**/stack.yaml.lock') }}-
```

### haskellおよびstackのセットアップをする

Haskell stackを使うので、`actions/setup-haskell`のアクションを借ります
ghcのバージョンは手元にあったものに合わせました。とりあえず。

```yaml
      - uses: actions/setup-haskell@v1.1.2
        with:
          ghc-version: '8.8.1'
          stack-version: 'latest'
```

### publishコマンドを実行する

環境の準備がほぼできたので、あとはhakyllのビルドをしておしまいです。
その前に、**gitのuserを`github-actions`に設定**しておきます。このアカウントにすると、内部トークンを使ってくれます。
また、ビルド周りのコマンドはMakefileにしまってあったのでそのまま使います。

```yaml
      - name: run publish
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com
          git switch source
          make publish
          git push origin publish
```

# 参考にしたサイト

- [ncaq -- HaskellプログラムをGitHub Actionsでビルドしてクロスプラットフォーム向けにバイナリをReleaseにアップロードする](https://www.ncaq.net/2020/04/05/15/54/26/)
- [Github -- actions/setup-haskell](https://github.com/actions/setup-haskell)
- [Github Docs -- Caching dependencies to speed up workflows](https://docs.github.com/en/actions/configuring-and-managing-workflows/caching-dependencies-to-speed-up-workflows)
- [Github -- actions/checkout#push-a-commit-using-the-built-in-token](https://github.com/actions/checkout#push-a-commit-using-the-built-in-token)
