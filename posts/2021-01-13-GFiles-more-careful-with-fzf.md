* fzf.vimでカレントディレクトリ以外のGitファイルを検索
    :PROPERTIES:
    :DATE: [2021-01-14 Thu]
    :TAGS: :fzf.vim:fzf:vim:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
** =GFiles=は便利
   :PROPERTIES:
   :CUSTOM_ID: gfilesは便利
   :END:
=GFiles=は、カレントディレクトリにgitレポジトリがあると仮定して、そのレポジトリに認識されるファイル(=一度はコミットされているファイル)
の一覧を作り出します。

しかし、場合によっては「カレントディレクトリ以外のgitレポジトリにあるファイルを参照したい」ことがあると思います。

例えば、私は普段プロジェクトに取り組んでいる最中にブログを書いたりするのですが、まさにその時などです。
カレントディレクトリはプロジェクトディレクトリのままで、ブログのレポジトリに対して=GFiles=を使いたいのです。

これは公式の方法が(多分)ないので直接書き換えます。

=~/.vim/bundle/fzf.vim/autoload/fzf/vim.vim=の=s:get_git_root()=がgitレポジトリを見つけるためのコードなので、ここにfugitiveが使う=b:git_dir=変数の中身を適用するように編集します。

#+begin_example
  function! s:get_git_root()
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    return v:shell_error ? '' : root
  endfunction
#+end_example

こうだったのが

#+begin_example
  function! s:get_git_root()
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    let root_ = root ? root : b:git_dir
    return v:shell_error ? '' : root_
  endfunction
#+end_example

こうすることにより、=git_dir=も有効に検索されるようになりました。
