* Github ActionsでGithub Pagesのリリースを自動化する
    :PROPERTIES:
    :DATE: [2020-08-07 Fri]
    :TAGS: :github actions:github pages:hakyll:ブログ:自動化:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
[[https://cj-bc.github.io/blog][このブログ]]の生成をGithub
Actionsで行えるようにしたので、その時のメモ\\
尚、現在のworkflowファイルは[[https://github.com/Cj-bc/blog/blob/source/.github/workflows/publish.yaml][Cj-bc/blog
-- .github/workflows/publish.yaml]]にあります。

** 前提
   :PROPERTIES:
   :CUSTOM_ID: 前提
   :END:

- 静的サイトジェネレーターはHakyll
- ほぼ[[https://jaspervdj.be/hakyll/tutorials/github-pages-tutorial.html][チュートリアル]]通りの作りになっている

  - =master=の代わりに=publish=、=develop=の代わりに=source=にしてある

- Github Pageでホスティング

** workflowファイルを作成する
   :PROPERTIES:
   :CUSTOM_ID: workflowファイルを作成する
   :END:
*** トリガーの設定
    :PROPERTIES:
    :CUSTOM_ID: トリガーの設定
    :END:
自分の環境では、=source=ブランチの中身を使ってビルド→=publish=ブランチにおいて公開、という手順を追っているので、=source=ブランチにpushされたときだけ走るようにします

#+begin_example
  on:
    push:
      branches: [source]
#+end_example

*** Jobの作成
    :PROPERTIES:
    :CUSTOM_ID: jobの作成
    :END:
Jobを作成します。環境はstackが動けばどこでも問題がないので、ubuntuにします。

#+begin_example
  jobs:
    runPublish:
      name: run publish
      runs-on: ubuntu-latest
#+end_example

*** ステップの作成
    :PROPERTIES:
    :CUSTOM_ID: ステップの作成
    :END:
ここからstepを作っていきます。

**** 必要なブランチをcheckoutする
     :PROPERTIES:
     :CUSTOM_ID: 必要なブランチをcheckoutする
     :END:
今回、トリガー対象のブランチ=source=の他に=publish=ブランチを使っています。
しかし、デフォルトではローカルに=publish=ブランチは存在しません。\\
なので、=actions/checkout=に、全てのブランチとタグの履歴をfetchする=fetch-depth: 0=を付け足す必要があります。

#+begin_example
      steps:
        - uses: actions/checkout@v2
          with:
            fetch-depth: 0
#+end_example

**** キャッシュの設定をする
     :PROPERTIES:
     :CUSTOM_ID: キャッシュの設定をする
     :END:
ビルドはなかなかに重い(現在の構成で約4,50分くらい)ので、なるべくキャッシュを活用します。\\
キャッシュには=actions/cache@v2=を使用します。キャッシュしたいものを生成するactionの前に実行し、キャッシュがあればそこをスキップするようにします。
キャッシュ対象は=~/.stack=ディレクトリです。\\
これは、[ncaqさんの記事][ncaq -- HaskellプログラムをGitHub
Actionsでビルドしてクロスプラットフォーム向けにバイナリをReleaseにアップロードする]から大体を引用させていただきました。

#+begin_example
        - name: Cache stack
          uses: actions/cache@v2
          with:
            path: ~/.stack
            key: stack-${{ hashFiles('**/stack.yaml.lock') }}-${{ hashFiles('**/package.yaml') }}
            restore-keys: |
              ${{ runner.os }}-stack-${{ hashFiles('**/stack.yaml.lock') }}-
#+end_example

**** haskellおよびstackのセットアップをする
     :PROPERTIES:
     :CUSTOM_ID: haskellおよびstackのセットアップをする
     :END:
Haskell
stackを使うので、=actions/setup-haskell=のアクションを借ります。\\
ghcのバージョンは、とりあえず手元にあったものに合わせました。

#+begin_example
        - uses: actions/setup-haskell@v1.1.2
          with:
            ghc-version: '8.8.1'
            stack-version: 'latest'
#+end_example

**** publishコマンドを実行する
     :PROPERTIES:
     :CUSTOM_ID: publishコマンドを実行する
     :END:
環境の準備がほぼできたので、あとはhakyllのビルドをしておしまいです。\\
その前に、*gitのuserを=github-actions=に設定*しておきます。このアカウントにすると、内部トークンを使ってくれます。\\
また、ビルド周りのコマンドはMakefileにしまってあったのでそのまま使います。

#+begin_example
        - name: run publish
          run: |
            git config user.name github-actions
            git config user.email github-actions@github.com
            git switch source
            make publish
            git push origin publish
#+end_example

** 参考にしたサイト
   :PROPERTIES:
   :CUSTOM_ID: 参考にしたサイト
   :END:

- [[https://www.ncaq.net/2020/04/05/15/54/26/][ncaq --
  HaskellプログラムをGitHub
  Actionsでビルドしてクロスプラットフォーム向けにバイナリをReleaseにアップロードする]]
- [[https://github.com/actions/setup-haskell][Github --
  actions/setup-haskell]]
- [[https://docs.github.com/en/actions/configuring-and-managing-workflows/caching-dependencies-to-speed-up-workflows][Github
  Docs -- Caching dependencies to speed up workflows]]
- [[https://github.com/actions/checkout#push-a-commit-using-the-built-in-token][Github
  -- actions/checkout#push-a-commit-using-the-built-in-token]]
