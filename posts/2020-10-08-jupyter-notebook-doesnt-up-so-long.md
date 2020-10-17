---
title: jupyter notebookがうまく起動しなかった
tags:
  - python
  - jupyter
  - macOS
kind: memo
date: October 10, 2020
---

```sh
$ jupyter notebook
```

だと、鯖は立ち上がるもののページが読み込めずうまくいかなかった。
試しに、[この記事](https://qiita.com/ciela/items/0e0392f600c92b93d7c6)に従ってみたところ接続できた。
よくわからないけど、まぁ動いたのでよし。別段VM環境でもなかったんだけどなぁ

```sh
$ jupyter notebook --ip=\*
```
