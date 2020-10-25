Player Inputが上手く使えないと思ったら単純なミスだった

# tl;dr

UnityEventを使用する場合、Eventに登録するスクリプトは、そのInspectorビューから選択し、スクリプトファイルそのものを入れないようにする

---

Player Inputは、Unityで`2019.1`から追加された、`Input`に取って変わる新しい入力管理システムです。
詳しくは[新しい Input System のご紹介 -- blogs.unity3d.com](https://blogs.unity3d.com/jp/2019/10/14/introducing-the-new-input-system/)を参照してください。


# 環境

ソフトウェア   バージョン
-------------  --------------------- -
Unity          2019.4.11f1 Personal
InputSystem    1.0.0

# 現状

基本的には[Quick Start Guide](https://docs.unity3d.com/Packages/com.unity.inputsystem@1.0/manual/QuickStartGuide.html)に沿って作業をしています。(`Input System`は導入済とします。)

1. 入力を反映させたい`GameObject`に`PlayerInput`をattachします。
2. "Create Actions"を押し、新しい`Action Asset`を作成します
3. "Quick Start Guide"に従って、入力を`Unity Events`で受けとるようにします。
4. 今回は必要なかったので、デフォルトで入っているActionを自分で使うものに入れかえました
5. `1.`の`GameObject`に戻り、`PlayerInput`のEvents欄にScript fileを指定します
6. あれ!?`No Function`しか出てこない!?

# 原因

今回の原因は、上記の`5.`にある **Events欄に設定したもの** でした。
ここで、私は「スクリプトファイル自体」を選択していましたが、そうではなく、「実際に使いたいオブジェクトに紐づけられている該当ファイルのインスタンスを渡してると、上手くいきます。

## もう一つ考えられる原因

今回は違いましたが、調べている間に見つけたのが[これ](https://forum.unity.com/threads/cant-assign-public-script-function-to-player-input-component-new-input-system.881032/)で、「コールバック関数の引数は`InputAction.CallbackContext callbackContext`にしないといけない、というもの。
