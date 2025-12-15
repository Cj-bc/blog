---
title: 大量のasmdefのあるプロジェクトでomnisharpがタイムアウトするのを対策する
tags: unity omnisharp lsp
author: Cj-bc
date: [2025-12-12 Fri]
kind: Knowledge
progress: WIP
status: Normal
—--

# 状況

EditorはEmacs、lspクライアントはeglot、UnityプロジェクトのLSPとしてomnisharp-roslynを使っている。omnisharpがあまりにも立ち上がらないのでログを見てみたところ、プロジェクトファイルの読み込み中にtimeoutさせられていることがわかった。timeout までの時間を5分間までなどと伸ばしたりもしてみたが全然解消されなかった。

# 解決策

`omnisharp.json` に下記を追加すると、全てのプロジェクトを読み込むのではなく開いているファイルから参照されているものだけを読み込むようになる。

```json
{ "msbuild": {
    "loadProjectsOnDemand": true
  }
}

```

あんまりドキュメントがないが、コード上には説明がある。

> If true, MSBuild project system will only be loading projects for files that were opened in the editor as well as referenced projects, recursively.

https://github.com/OmniSharp/omnisharp-roslyn/blob/83fd615eafff33e297a9f59280d929cf09ec0d3c/src/OmniSharp.MSBuild/Options/MSBuildOptions.cs#L15

# 小話

ちなみにこれはclaudeとgeminiが教えてくれた。そのやり取りの途中で他にもいくつか教えてくれたのを載せておく。

`omnisharp.json`で、検索対象のファイルパスを絞れる:
```json

{
  "fileOptions": {
    "systemExcludeSearchPatterns": [
      "**/node_modules/**",
      "**/Library/**",
      "**/Temp/**",
      "**/Logs/**",
      "**/obj/**",
      "**/bin/**"
    ]
  }
}
```

コード: https://github.com/OmniSharp/omnisharp-roslyn/blob/83fd615eafff33e297a9f59280d929cf09ec0d3c/src/OmniSharp.Shared/Options/FileOptions.cs#L7
