---
title: fzf.vimでカレントディレクトリ以外のGitファイルを検索
tags:
  - fzf.vim
  - fzf
  - vim
kind: note
date: January 14, 2021
---


# `GFiles`は便利

`GFiles`は、カレントディレクトリにgitレポジトリがあると仮定して、そのレポジトリに認識されるファイル(=一度はコミットされているファイル)
の一覧を作り出します。  

しかし、場合によっては「カレントディレクトリ以外のgitレポジトリにあるファイルを参照したい」ことがあると思います。  

例えば、私は普段プロジェクトに取り組んでいる最中にブログを書いたりするのですが、まさにその時などです。
カレントディレクトリはプロジェクトディレクトリのままで、ブログのレポジトリに対して`GFiles`を使いたいのです。

これは公式の方法が(多分)ないので直接書き換えます。

`~/.vim/bundle/fzf.vim/autoload/fzf/vim.vim`の`s:get_git_root()`がgitレポジトリを見つけるためのコードなので、ここにfugitiveが使う`b:git_dir`変数の中身を適用するように編集します。

``` vim
function! s:get_git_root()
  let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  return v:shell_error ? '' : root
endfunction
```

こうだったのが

``` vim
function! s:get_git_root()
  let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  let root_ = root ? root : b:git_dir
  return v:shell_error ? '' : root_
endfunction
```

こうすることにより、`git_dir`も有効に検索されるようになりました。
