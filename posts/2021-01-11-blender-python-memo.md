---
title: VRM_IMPORTER_for_Blender \#23 作業メモ
tags:
  - blender
  - python
kind: scratch
date: January 11, 2021
---

# 追加されたシェーダーを探す

## 場所の特定

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

## 実際にshaderを追加している部分

このコードである。そして、読めば字の如くだが、レポジトリにある`resources/material_node_groups.blend`
にある`node_groups`の中でBlenderに存在していないものがあれば
`data_to.node_groups.append()`して追加している。  
結論から言うと[`node_groups`](https://docs.blender.org/api/current/bpy.types.BlendData.html?highlight=node_groups#bpy.types.BlendData.node_groups)は
nodeで表現されるもの(オブジェクト？)、つまり`Shading`/`Textures`/`Compositin`に関わるものの集合である。
([公式doc](https://docs.blender.org/api/current/bpy.types.NodeTree.html#bpy.types.NodeTree))  
type()によると、`bpy.data`は`bpy.types.BlendData`であるので、`node_groups`は
[`bpy.types.BlendData.node_groups`](https://docs.blender.org/api/current/bpy.types.BlendData.html?highlight=node_groups#bpy.types.BlendData.node_groups)
である。
ここで、なんとなく`bpy.data`を見てみると`bpy.data.node_groups`に追加されてることがわかる。

<details>
<summary>`bpy.data.node_groups`までたどり着く道のりメモ(でもよくわからなくて落書き)</summary>
`data_to`は[`bpy.data.libraries.load`](https://docs.blender.org/api/current/bpy.types.BlendDataLibraries.html#bpy.types.BlendDataLibraries.load)から返されている。
`bpy.data`が[`BlendData`](https://docs.blender.org/api/current/bpy.types.BlendData.html)のインスタンスであることから
`bpy.data.libraries.load`は[`BlendDataLibraries.load`](https://docs.blender.org/api/current/bpy.types.BlendDataLibraries.html#bpy.types.BlendDataLibraries.load)である。  

...で、なんとなく`bpy.data`を見る、に戻る
</details>



`node_groups`の中で入力を受け付けてるものなら`.inputs`にある。
今回でいうと、`MToon`マテリアルにある`NomalmapTexture`というtypoを直したいので、
`bpy.data.node_groups['MToon_unversioned'].input['NomalmapTexture']`を参照する

# 今行き詰まっている問題

## bpy_prop_collectionに追加できない

これをtypoが直った`bpy.data.node_groups['MToon_unversioned'].input['NormalmapTexture']`に変えたいのだけど、
どうやら`input['NomalmapTexture']`の型である`bpy_prop_collection`がC実装なようで、普段のpythonのようにはいかない。
具体的にいうと

``` python
bpy.data.node_groups['MToon_unversioned'].input['NormalmapTexture'] = bpy.data.node_groups['MToon_unversioned'].input['NomalmapTexture']
```

では以下のようにエラーを吐かれてうまくいかない。

``` python-repl
>>> mtonNode = bpy.data.node_groups['MToon_unversioned']
>>> mtoonNode.inputs['NormalmapTexture'] = mtoonNode.inputs['NomalmapTexture']
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: bpy_prop_collection[key]: invalid key, must be a string or an int, not str
```

### 試したこと

[`bpy_prop_collection`](https://docs.blender.org/api/current/bpy.types.bpy_prop_collection.html?highlight=bpy_prop_collection#bpy.types.bpy_prop_collection)のドキュメントと`dir(mtoonNode.inputs[0])`を読んでみた所、
ドキュメントには書かれていなかったけど`move`と`new`があった。

``` python-repl
>>> dir(mtoonNode.inputs)
['__bool__', '__contains__', '__delattr__', '__delitem__', '__doc__'
, '__doc__', '__getattribute__', '__getitem__', '__iter__', '__len__'
, '__module__', '__setattr__', '__setitem__', '__slots__', 'bl_rna'
, 'clear', 'find', 'foreach_get', 'foreach_set', 'get'
, 'items', 'keys', 'move', 'new', 'remove', 'rna_type', 'values']
```


それぞれの挙動を試してみたが、どっちもうまく動かず...というか挙動がわからなかった

#### `new()`

<details> <summary>Replの結果ですが長いので折りたたみ</summary>
``` python-repl
>>> mtoonNode.inputs
bpy.data...inputs
>>> mtoonNode
bpy.data.node_groups['MToon_unversioned']
>>> mtoonNode.inputs.new
<bpy_func NodeTreeInputs.new()>
>>> mtoonNode.inputs.new()
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: NodeTreeInputs.new(): required parameter "type" not specified
>>> # mtoonNode.inputs['NomalmapTexture']から値を拝借
>>> mtoonNode.inputs.new('RGBA')
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: NodeTreeInputs.new(): required parameter "name" not specified
>>> mtoonNode.inputs.new('RGBA', 'NormalmapTexture')
>>> mtoonNode.inputs
bpy.data...inputs
>>> mtoonNode.inputs['NormalmapTexture']
Traceback (most recent call last):
  File "<console>", line 1, in <module>
KeyError: 'bpy_prop_collection[key]: key "NormalmapTexture" not found'
>>> mtoonNode.inputs.items()
[('MainTexture', bpy.data...inputs[0])
, ('MainTextureAlpha', bpy.data...inputs[1])
, ('ShadeTexture', bpy.data...inputs[2])
, ('ReceiveShadow_Texture_alpha', bpy.data...inputs[3])
, ('NomalmapTexture', bpy.data...inputs[4])
, ('ShadingGradeTexture', bpy.data...inputs[5])
, ('Emission_Texture', bpy.data...inputs[6])
, ('SphereAddTexture', bpy.data...inputs[7])
, ('OutlineWidthTexture', bpy.data...inputs[8])
, ('UV_Animation_Mask_Texture', bpy.data...inputs[9])
, ('DiffuseColor', bpy.data...inputs[10])
, ('ShadeColor', bpy.data...inputs[11])
, ('EmissionColor', bpy.data...inputs[12])
, ('OutlineColor', bpy.data...inputs[13])
, ('RimColor', bpy.data...inputs[14])
, ('RimTexture', bpy.data...inputs[15])
, ('RimLightingMix', bpy.data...inputs[16])
, ('RimFresnelPower', bpy.data...inputs[17])
, ('RimLift', bpy.data...inputs[18])
, ('CutoffRate', bpy.data...inputs[19])
, ('BumpScale', bpy.data...inputs[20])
, ('ReceiveShadowRate', bpy.data...inputs[21])
, ('ShadeShift', bpy.data...inputs[22])
, ('ShadeToony', bpy.data...inputs[23])
, ('ShadingGradeRate', bpy.data...inputs[24])
, ('LightColorAttenuation', bpy.data...inputs[25])
, ('IndirectLightIntensity', bpy.data...inputs[26])
, ('OutlineWidth', bpy.data...inputs[27])
, ('OutlineScaleMaxDistance', bpy.data...inputs[28])
, ('OutlineLightingMix', bpy.data...inputs[29])
, ('OutlineWidthMode', bpy.data...inputs[30])
, ('OutlineColorMode', bpy.data...inputs[31])
, ('UV_Scroll_X', bpy.data...inputs[32])
, ('UV_Scroll_Y', bpy.data...inputs[33])
, ('UV_Scroll_Rotation', bpy.data...inputs[34])]
```
</details>

#### move()



<details> <summary> Replの結果。長いため折りたたみ。 </summary>
``` python-repl
>>> mtoonNode.inputs.move()
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: NodeTreeInputs.move(): required parameter "from_index" not specified
>>> mtoonNode.inputs.move(4)
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: NodeTreeInputs.move(): required parameter "to_index" not specified
>>> mtoonNode.inputs.move(4, 35)
>>> mtoonNode.inputs.items()
[('MainTexture', bpy.data...inputs[0]), ('MainTextureAlpha', bpy.data...inputs[1])
, ('ShadeTexture', bpy.data...inputs[2])
, ('ReceiveShadow_Texture_alpha', bpy.data...inputs[3])
, ('NomalmapTexture', bpy.data...inputs[4])
, ('ShadingGradeTexture', bpy.data...inputs[5])
, ('Emission_Texture', bpy.data...inputs[6])
, ('SphereAddTexture', bpy.data...inputs[7])
, ('OutlineWidthTexture', bpy.data...inputs[8])
, ('UV_Animation_Mask_Texture', bpy.data...inputs[9])
, ('DiffuseColor', bpy.data...inputs[10])
, ('ShadeColor', bpy.data...inputs[11])
, ('EmissionColor', bpy.data...inputs[12])
, ('OutlineColor', bpy.data...inputs[13])
, ('RimColor', bpy.data...inputs[14])
, ('RimTexture', bpy.data...inputs[15])
, ('RimLightingMix', bpy.data...inputs[16])
, ('RimFresnelPower', bpy.data...inputs[17])
, ('RimLift', bpy.data...inputs[18])
, ('CutoffRate', bpy.data...inputs[19])
, ('BumpScale', bpy.data...inputs[20])
, ('ReceiveShadowRate', bpy.data...inputs[21])
, ('ShadeShift', bpy.data...inputs[22])
, ('ShadeToony', bpy.data...inputs[23])
, ('ShadingGradeRate', bpy.data...inputs[24])
, ('LightColorAttenuation', bpy.data...inputs[25])
, ('IndirectLightIntensity', bpy.data...inputs[26])
, ('OutlineWidth', bpy.data...inputs[27])
, ('OutlineScaleMaxDistance', bpy.data...inputs[28])
, ('OutlineLightingMix', bpy.data...inputs[29])
, ('OutlineWidthMode', bpy.data...inputs[30])
, ('OutlineColorMode', bpy.data...inputs[31])
, ('UV_Scroll_X', bpy.data...inputs[32])
, ('UV_Scroll_Y', bpy.data...inputs[33])
, ('UV_Scroll_Rotation', bpy.data...inputs[34])]
>>> mtoonNode.inputs.values()
[bpy.data...inputs[0]
, bpy.data...inputs[1], bpy.data...inputs[2]
, bpy.data...inputs[3], bpy.data...inputs[4]
, bpy.data...inputs[5], bpy.data...inputs[6]
, bpy.data...inputs[7], bpy.data...inputs[8]
, bpy.data...inputs[9], bpy.data...inputs[10]
, bpy.data...inputs[11], bpy.data...inputs[12]
, bpy.data...inputs[13], bpy.data...inputs[14]
, bpy.data...inputs[15], bpy.data...inputs[16]
, bpy.data...inputs[17], bpy.data...inputs[18]
, bpy.data...inputs[19], bpy.data...inputs[20]
, bpy.data...inputs[21], bpy.data...inputs[22]
, bpy.data...inputs[23], bpy.data...inputs[24]
, bpy.data...inputs[25], bpy.data...inputs[26]
, bpy.data...inputs[27], bpy.data...inputs[28]
, bpy.data...inputs[29], bpy.data...inputs[30]
, bpy.data...inputs[31], bpy.data...inputs[32]
, bpy.data...inputs[33], bpy.data...inputs[34]]
>>> bpy.data...inputs[1]
  File "<console>", line 1
    bpy.data...inputs[1]
              ^
SyntaxError: invalid syntax
>>>
```
</details>