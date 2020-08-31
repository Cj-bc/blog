---
title: Blender docs -- data block
tags:
  - blender
  - document
  - translation
  - wip
date: August 19, 2020
---


公式: <https://docs.blender.org/manual/ja/2.80/files/data_blocks.html>

# Data blocks

いかなるBlenderプロジェクトの基本単位は`data-block`です。`data-block`の例としては: meshes, objects, materials, textures, node trees, scenes, texts, brushes, そして workspace

`data-block`は、とても異なる種類のデータの全体的な抽象であり、共通の基本的な`feature`であるプロパティと`behaviors`に重心を置いています。

いくつかの共通した特徴は:

- `blend-file`の`primary contents`です。
- 再利用やインスタンス化のために、違いを参照することができます。(Child/parent, object/object-data, materials/images, in modifiers or constraints too...)
- それぞれの名前は、`blend-file`内で同じタイプの中で`unique`です。
- 追加、削除、編集、複製が可能です。
- ファイル間で`link`することができます。(限られた種類の`data-blocks`のみです)
- それぞれ独自のアニメーションデータを持つことができます。
- それぞれ[Custom properties](https://docs.blender.org/manual/ja/2.80/files/data_blocks.html#files-data-blocks-custom-properties)を持つことができます。

ユーザーは`typically`高レベルの`data type`を扱うことになります(`obects`, `meshes`など)。
複雑なプロジェクトを扱う場合、特に`inter-linking blend-files`の場合、`data-block`の管理はより重要になります。
それ用の主なエディターは[Outliner](https://docs.blender.org/manual/ja/2.80/editors/outliner.html)です

Blender内の全てのデータが`data-block`なわけではありません。例えば、`bones`, `sequence strips`や`vertex groups`は違っており、
それぞれ`armature`、`scene`、`mesh types`に付属(`belong to`)しています。


# Life Time

全ての`data-block`は`usage counted`(`reference count`)を持っており、一つ以上である場合は、UIの中で`data-block`の名前の右側に`current user`の数が表示されます。

Blenderは、使用されていないデータは最終的に削除されるという`general rule`に従っています。

作業中にたくさんのデータを追加・削除することは一般的なため、全ての`data-block`を一つ一つ手動で管理する必要がないのは利点です。

これは、`blend-file`を書き込む際に、`zero user`な`data-block`をスキップする仕組みになっています。


# Protected

`zero user`な`data-block`は保存されないため、時にはユーザーのことを考えずにデータの保存を強制させたい時があるでしょう。

もし、`blend-file`を`library`として使っていたり、他のファイルから`link`したりされたりする目的で使っていた場合、
突然削除されないように気をつける必要があります。

`data-block`を`protect`するためには、その`data-block`の名前の横にある盾のボタンを使用します。
そうすると、その`data-block`はblenderによって自動的に削除されることは無くなりますが、必要ならば手動で削除することができます。


# Sharing

`data-block`は他の`data-block`間でも共有できます。

よくデータの共有が行われる例:

- `materials`間で`textures`を共有する
- `objects`(`instances`)間で`meshes`を共有する
- `objects`間で`animated actions`を共有する。例えば、全てのライトが同時に`dim`するようにします。


`data-block`をファイル間でも共有できます、詳しくは:

- [linked libraries](https://docs.blender.org/manual/ja/2.80/files/linked_libraries.html)


# Making Single User

`data-block`が複数のユーザーによって共有されている時、あるユーザーのためにコピーを作成することができます。
そうするには、名前の右にある`user-count`ボタンを押してください。そうすることにより、その`data-block`を複製してその用途のみに`assign`します。

## 注釈

`Objects`は`single-user`になるためにより発展的な`actions`を持っています。[彼らのドキュメント](https://docs.blender.org/manual/ja/2.80/scene_layout/object/editing/duplication.html)を参照してください。

# Removing Data-Blocks


