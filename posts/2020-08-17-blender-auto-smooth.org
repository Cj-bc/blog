* blenderのSmooth
    :PROPERTIES:
    :DATE: [2020-08-17 Mon]
    :TAGS: :blender:memo:tips:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
Blenderには、面と面を補完して滑らかに表示する=shade smooth=という機能があります。
しかし、何も考えずに使おうとすると思わぬところが補完され、予期せぬ結果になることが多々起こります。

#+caption: shade flatの結果
[[https://pbs.twimg.com/media/Efm72cmU8AI3H5K?format=jpg&name=medium]]

#+caption: shade smoothの結果
[[https://pbs.twimg.com/media/Efm74u6UcAEU2nM?format=jpg&name=medium]]

** Auto Smoothを使おう
   :PROPERTIES:
   :CUSTOM_ID: auto-smoothを使おう
   :END:
Auto
Smoothは、面の角度によって=shade smooth=と=shade flat=を使い分けてくれる機能です。
[[https://blender-cg.net/smooth-flat/][blender-cg.netさんの記事]]で知りました。

[[https://docs.blender.org/manual/ja/2.80/modeling/meshes/structure.html#auto-smooth][公式リファレンス(英語)]]

これを使うと、かなり快適に使うことができます！わーい！！

#+caption: auto smoothの場所
[[https://pbs.twimg.com/media/Efm8n4uUYAALg-g?format=png&name=small]]

#+caption: auto smoothを適用してみた結果
[[https://pbs.twimg.com/media/Efm8pyjU8AAU01a?format=jpg&name=medium]]
