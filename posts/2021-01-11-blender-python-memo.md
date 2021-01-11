---
title: VRM_IMPORTER_for_Blender #23 作業メモ
tags:
  - blender
  - python
kind: scratch
date: January 11, 2021
---

# 追加されたシェーダーを探す

そもそもファイルがどこに追加されているのかを確かめる必要がある。
そこで、`__init__.py`を参照する。(どうでもいいけど中身のある`__init__.py`は初めて見た)  
Blenderは、Addonが追加されるとクラスなどを登録するために`register()`という関数を探して実行する。
以下がこのAddonの`register()`関数。
([githubで確認する](https://github.com/saturday06/VRM_IMPORTER_for_Blender/blob/a14835bfbc573a1d8f2be2a74ed198da46a573e4/__init__.py#L277-L285))

``` python
# アドオン有効化時の処理
def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.TOPBAR_MT_file_import.append(menu_import)
    bpy.types.TOPBAR_MT_file_export.append(menu_export)
    bpy.types.VIEW3D_MT_armature_add.append(add_armature)
    # bpy.types.VIEW3D_MT_mesh_add.append(make_mesh)
    bpy.app.handlers.load_post.append(add_shaders)
```

明らかに`bpy.app.handlers.load_post.append(add_shaders)`が怪しい。というか、`add_shaders`という
わかりやすい名前があるので間違い無くここで追加している。
ということで`add_shaders`を見てみると
([githubで確認する](https://github.com/saturday06/VRM_IMPORTER_for_Blender/blob/a14835bfbc573a1d8f2be2a74ed198da46a573e4/__init__.py#L245-L253))

``` python
@persistent
def add_shaders(self):
    filedir = os.path.join(
        os.path.dirname(__file__), "resources", "material_node_groups.blend"
    )
    with bpy.data.libraries.load(filedir, link=False) as (data_from, data_to):
        for nt in data_from.node_groups:
            if nt not in bpy.data.node_groups:
                data_to.node_groups.append(nt)
```

このコードである。そして、読めば字の如くだが、レポジトリにある`resources/material_node_groups.blend`
を読み込んでその中にある`node_groups`を取得、Blenderに存在していないものがあれば
`data_to.node_groups.append()`して追加している。  
結論から言うと[`node_groups`](https://docs.blender.org/api/current/bpy.types.BlendData.html?highlight=node_groups#bpy.types.BlendData.node_groups)は
nodeで表現されるもの(オブジェクト？)、つまり`Shading`/`Textures`/`Compositin`に関わるものの集合である。
([公式doc](https://docs.blender.org/api/current/bpy.types.NodeTree.html#bpy.types.NodeTree))  
type()によると、`bpy.data`は`bpy.types.BlendData`であるので、`node_groups`は
[`bpy.types.BlendData.node_groups`](https://docs.blender.org/api/current/bpy.types.BlendData.html?highlight=node_groups#bpy.types.BlendData.node_groups)
である。
ここで、なんとなく`bpy.data`を見てみると

<details>
<summary>もうちょい詳しく(でもよくわからなくて落書き)</summary>
`data_to`は[`bpy.data.libraries.load`](https://docs.blender.org/api/current/bpy.types.BlendDataLibraries.html#bpy.types.BlendDataLibraries.load)から返されている。
`bpy.data`が[`BlendData`](https://docs.blender.org/api/current/bpy.types.BlendData.html)のインスタンスであることから
`bpy.data.libraries.load`は[`BlendDataLibraries.load`](https://docs.blender.org/api/current/bpy.types.BlendDataLibraries.html#bpy.types.BlendDataLibraries.load)である。  

</details>

`bpy.data.node_groups`。そこから、入力を受け付けてるものなら`.inputs`にある。
今回でいうと、`MToon`マテリアルにある`NomalmapTexture`というtypoを直したいので、
`bpy.data.node_groups['MToon_unversioned'].input['NomalmapTexture']`を参照する

これをtypoが直った`bpy.data.node_groups['MToon_unversioned'].input['NormalmapTexture']`に変えたいのだけど、

``` python
bpy.data.node_groups['MToon_unversioned'].input['NormalmapTexture'] = bpy.data.node_groups['MToon_unversioned'].input['NomalmapTexture']
```

では以下のようにエラーを吐かれてうまくいかない。

```
>>> mtonNode = bpy.data.node_groups['MToon_unversioned']
>>> mtoonNode.inputs['NormalmapTexture'] = mtoonNode.inputs['NomalmapTexture']
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: bpy_prop_collection[key]: invalid key, must be a string or an int, not str
```

なので、[`bpy_prop_collection`](https://docs.blender.org/api/current/bpy.types.bpy_prop_collection.html?highlight=bpy_prop_collection#bpy.types.bpy_prop_collection)
のドキュメントと`dir(mtoonNode.inputs[0])`を読んでみた所、
ドキュメントには書かれていなかったけど`move`と`new`があった。
これの挙動も確認しなくては...

```
>>> dir(mtoonNode.inputs)
['__bool__', '__contains__', '__delattr__', '__delitem__', '__doc__', '__doc__', '__getattribute__', '__getitem__', '__iter__', '__len__', '__module__', '__setattr__', '__setitem__', '__slots__', 'bl_rna', 'clear', 'find', 'foreach_get', 'foreach_set', 'get', 'items', 'keys', 'move', 'new', 'remove', 'rna_type', 'values']])
