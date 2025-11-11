---
title: ブログ記事をGithub issueから投稿出来るようにする
tags: github blog
author: Cj-bc
Kind: Memo
progress: WIP
status: Normal
---

# モチベーション

このブログの記事はorg-modeで記述され、gitにコミットされて管理されています。このワークフローはPCではうまく機能するのですが、スマホで行おうとすると途端に不都合が出てきます。
org文章エディタとして優秀なgitクライアントを探す、ということになるのですが、これがなかなか難しい。というか、org文章対応のものでgit連携できているものがない。自作すれば良いというのもそうなのですが、ひとまずは手軽に書ける方法を探していました。

そんなところで「Github issueから投稿したい」とは思っていつつ先延ばしにしていた矢先、同じ発想で管理されている方のブログ記事（[GitHub Issue から Markdown ファイルを生成してブログ記事を公開する -- ikuma-t.com](https://ikuma-t.com/blog/publish-blog-from-github-issue/)）を発見しました。

そこで、きっかけもできたことですしこれをベースにして環境を整えてみる事にします

# 基本の流れ
ikuma-t さんの記事とほぼ同じですが、一部書き換えています。

1. ユーザーが、特定のラベルのついた issue を作成
2. **[変更]** issue に `/publish` コメントがなされた時、Github Actionsを用いてPRに変換
3. PRをマージする事でgitに追加
4. 元からあるpublish Github Actionでビルド & publish

# issueコメントでの指示で発火するようにする

参考先のikuma-tさんの記事では「issueの作成時」に発火するようになっていました。
私は時間をかけて少しずつ記事を書くことが多いので、これだと発火のタイミングが早過ぎます。
そこで、issueの作成時ではなく「特定のコメントがついた時」に発火するように変更します。

## イベント種別の変更と権限の確認

issueのコメントに反応するため、イベントを `issue_comment` に変更します。  
又、外部の人が操作できてしまわないよう、issueがレポジトリの所有者によって開かれていること・コメントがレポジトリの所有者によるものである事を確認します。

```yaml
on:
  issue_comment:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    if: |
      github.event.issue_comment.issue.author_association == 'OWNER' 
      && github.event.issue_comment.sender.id == github.repository_owner
    steps:
      - uses: actions/checkout@v4
      ...
```

この時、ユーザーのチェックが通らないとjob自体がスキップされて「成功」とされるわけですが、「ユーザーが異なっていたらスキップする」挙動は仕様通りであるため「成功」の扱いで問題ないと思います。

# **[重要]** bodyを環境変数経由で渡すようにする

元々はお手本のように `run` 内に直接埋め込んでいました。

```yaml
        run: |
          echo -e "---
${{ github.event.issue.body }}" | sed -e "s/publishDate:/publishDate: $(TZ=-9 date -Iseconds)/" | sed -e "s/modDatetime:/modDatetime: $(TZ=-9 date -Iseconds)/" >> posts/${{ steps.define_title.outputs.title }}.md
```

しかし、こうするとバッククォートを含んだ内容の際にエラーを発されて失敗します。

     /home/runner/work/_temp/58e820d5-b1c6-4469-b9b1-79e1aff9d4fb.sh: line 124: unexpected EOF while looking for matching ``'
    Error: Process completed with exit code 2.

これは文字列置換のタイミングによるものなのかなと思っています。恐らくshellに渡される前に展開されるため、bashで直書きだと"バッククォートを含んだ文字列"としてbashに認識され、bash側のコマンド置換として処理されてしまうわけです。
そこで、[環境変数に埋め込んでしまう](https://github.com/Cj-bc/blog/commit/82241a53fa8c40f95ba12d4ba369b94ad6378bbc)事にしました。こうするとbashによってコマンド置換されずに済み、エラーが出ません。

```yaml
      - name: Create Content File
        run: |
          echo -e "---
${BODY}" | sed -e "s/publishDate:/publishDate: $(TZ=-9 date -Iseconds)/" | sed -e "s/modDatetime:/modDatetime: $(TZ=-9 date -Iseconds)/" >> posts/${{ steps.define_title.outputs.title }}.md
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          BODY: ${{ github.event.issue.body }}
```

# **[重要]]** 更新日時の更新を front matterのみに制限する

お手本の通りだと本文中にある `modTime:` を全て置き換えてしまいます。例えばこの記事などでは本文中にも同じ文字列があり、それを置き換えられてしまうと困るので、front matter内のものだけに限定します。
sedでも `t` コマンドでワンチャンいけるのではなかろうかと思ったのですが、[claude君に任せたらawkで書いてくれました](https://github.com/Cj-bc/blog/commit/15f57adbd193dabda5493ce872866705de71d406)。まぁ確かにその方が一般的。中身としては、 `---` が出現した回数を数えておき、きっかり1回のみ出現している最中だけ置換を行うというものです。

https://github.com/Cj-bc/blog/blob/b7157120f727dd9ebb5c71f72aa72024d75c955a/.github/workflows/new-post-from-issues.yaml#L26-L42


# 3rd party依存を減らす

昨今のセキュリティ事情もあり、なるべく外部依存を減らしたいのでgitコミットをコマンドの手書きに変更します。

```yaml

      - name: Commit Content File
         run: |
            git switch -c new_post/${{ steps.define_title.outputs.title }}
            git add *
            git commit -m "feat: new post"

```

# ブログ生成側への変更

現在のblogレポジトリの構成がこのワークフローに合致していない部分があるため、いくつかの修正をします。ここは他のブログでは参考にならない可能性が高いためセクションを分けて記述します。

## 規定のブランチを変更する

Github上での規定のブランチがビルド済みのコンテンツを保持している `publish` ブランチになっていますが、ワークフローは `source` に置きたいです。 `issue_comment` イベントは規定のブランチにあるワークフローからしか受け取れないため、変更する必要があります。
これはGithubのUIで変更するだけなので、簡単ですね。

## orgとmarkdown双方を使用できるようにする

現環境ではorg文書のみを使用するようになっているため、markdownも受け付けるように変更します。

とはいえ、ベースに使っているAstro collectionはネイティブでmarkdownファイルをサポートしています。そのため、Makefileで記事のファイルを移動する際に `*.org` だけでなく `*.md` も対象とするように変更すれば問題ない…はずです。

```diff
+ SHELL := /usr/bin/bash
  blog-build:
-   cp *.org 
+   shopt -s nullglob; cp *.{org,md}
```

ここで注意ですが、ブレース展開（brace expansion）を用いる場合は `SHELL` 変数を変更する必要があります。なぜならブレース展開はbashの機能であり、makeでデフォルトで使われるのはshだからです（[やらかしたコミット](https://github.com/Cj-bc/blog/commit/6f70cf64075c1161c06064c75a4673153fc67619)）又、ファイルがなかった場合にそのまま渡るのではなく空文字になるように `nullglob` も使います。Makefileのレシピは各行別の空間で行われ、影響を与えないようになっているため、 `nullglob` を設定するのはcpと同じ行である必要があります。


## issue作成用のテンプレートを作成する

毎回YAML frontmatterを手書きするのは怠いので、issue templateを使って先に埋めるようにします。
`.github/ISSUE_TEMPLATE/` 以下にmarkdownファイルを作成して記述していきます。今は[githubのwebページから設定するのが推奨](https://docs.github.com/ja/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)なようですが、直接作っても問題ありません。

```markdown
---
name: new blog post
about: used to create new blog post from GitHub issue
title: ''
labels: automation/new-post
assignees: ''
---

title: 
tags:
author: Cj-bc
Kind:data # [Memo | Diary | Knowledge | Advertisment | Translation | HowTo]
progress: WIP
status: Normal
—--

#

```

ブログ記事本体に含まれてほしいYAML frontmatterですが、きちんと上下 `---` で囲ってしまうとGithub actions用のものと衝突するようなので1番上側はダッシュを消しています。それを補うために、github actions側でファイル作成時に追記します

```diff

        - name: Create Content File
          run: |
-           echo -e "${{ github.event.issue.body }}" | sed -e "s/publishDate:/publishDate: $(TZ=-9 date -Iseconds)/" | sed -e "s/modDatetime:/modDatetime: $(TZ=-9 date -Iseconds)/" >> posts/${{ steps.define_title.outputs.title }}.md
+           echo -e "---
${{ github.event.issue.body }}" | sed -e "s/publishDate:/publishDate: $(TZ=-9 date -Iseconds)/" | sed -e "s/modDatetime:/modDatetime: $(TZ=-9 date -Iseconds)/" >> posts/${{ steps.define_title.outputs.title }}.md

        env:

尚、調べていたところドロップダウンなども使える [issue formsなるもの](https://docs.github.com/ja/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)がパブリックプレビューで存在するようです。選択式のもの（自分の例でいうと "Kind" メタデータなど）が多い場合はこちらの方が便利そうですね。
