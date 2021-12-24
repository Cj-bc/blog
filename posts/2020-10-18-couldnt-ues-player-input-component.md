Unity 2019.4.11f1 Personal InputSystem 1.0.0

** 現状
   :PROPERTIES:
   :CUSTOM_ID: 現状
   :END:
基本的には[[https://docs.unity3d.com/Packages/com.unity.inputsystem@1.0/manual/QuickStartGuide.html][Quick
Start
Guide]]に沿って作業をしています。(=Input System=は導入済とします。)

1. 入力を反映させたい=GameObject=に=PlayerInput=をattachします。
2. "Create Actions"を押し、新しい=Action Asset=を作成します
3. "Quick Start
   Guide"に従って、入力を=Unity Events=で受けとるようにします。
4. 今回は必要なかったので、デフォルトで入っているActionを自分で使うものに入れかえました
5. =1.=の=GameObject=に戻り、=PlayerInput=のEvents欄にScript
   fileを指定します
6. あれ!?=No Function=しか出てこない!?

** 原因
   :PROPERTIES:
   :CUSTOM_ID: 原因
   :END:
今回の原因は、上記の=5.=にある *Events欄に設定したもの* でした。
ここで、私は「スクリプトファイル自体」を選択していましたが、そうではなく、「実際に使いたいオブジェクトに紐づけられている該当ファイルのインスタンスを渡してると、上手くいきます。

*** もう一つ考えられる原因
    :PROPERTIES:
    :CUSTOM_ID: もう一つ考えられる原因
    :END:
今回は違いましたが、調べている間に見つけたのが[[https://forum.unity.com/threads/cant-assign-public-script-function-to-player-input-component-new-input-system.881032/][これ]]で、「コールバック関数の引数は=InputAction.CallbackContext callbackContext=にしないといけない、というもの。
