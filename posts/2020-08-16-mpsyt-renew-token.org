* mps-youtubeのAPIキーを更新する
    :PROPERTIES:
    :DATE: [2020-08-16 Sun]
    :TAGS: :mps-youtube:mpsyt:memo:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
mps-youtubeで音楽を聴こうと思ったら、以下のようなエラーが出た。

#+begin_quote
  Error fetching data. Possible network issue. Youtube Error 403: The
  request cannot be completed because you have exceeded your quota.
#+end_quote

ので、[[https://github.com/mps-youtube/mps-youtube/wiki/Troubleshooting#youtube-error-403-the-request-cannot-be-completed-because-you-have-exceeded-your-quota][mps-youtubeレポのトラブルシューティング]]に基づいて作業をする。\\
また、上記記事で参考にされている[[https://www.slickremix.com/docs/get-api-key-for-youtube/][slickremix.com
-- Get API Key for YouTube]]も参考にする。
ただし、上記記事では「手順3までやる」と書いてあるが、最後(8)までやる必要がある。

** 1. Google developpersにて、プロジェクトを作成してTokenを取得。
   :PROPERTIES:
   :CUSTOM_ID: google-developpersにてプロジェクトを作成してtokenを取得
   :END:
[[https://developers.google.com/]]
に飛び、一番下(右下)の=Google API Console=からコンソールを開く。

#+caption: console pic
[[/images/console_place.png]]

左上の=Google APIs=の文字の横に「Project」という部分があるので選択→右上の「新しいプロジェクト」からプロジェクトを作成する。\\
ダッシュボードの「APIとサービス」→「ライブラリ」からYouTube Data API
v3を選択し有効化。\\
最後に認証情報の作成が必要なので、あとはUIの流れに任せればTokenが手に入ります。

** 2. mps-youtubeで入力する
   :PROPERTIES:
   :CUSTOM_ID: mps-youtubeで入力する
   :END:
上記記事にあるとおり、以下のコマンドで入力する。一度appを終了させる必要があることに注意。

#+begin_example
  mps-youtube
  > set api_key <key value>
  > q # quit app
#+end_example
