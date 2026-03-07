---
title: uGUIのButtonはアニメーション遷移にSetTriggerする
tags: unity,ugui
author: Cj-bc
date: "[2026-03-06 11:16:24+00:00]"
publishDate: "[2026-03-06 11:16:24+00:00]"
modDatetime: "[2026-03-06 11:16:24+00:00]"
kind: Knowledge
progress: WIP
status: Normal
---


文字通りそのままですが、UnityのuGUIのButtonコンポーネントのtransitionにアニメーションを指定した際、具体的にAnimatorをどう使われるのかがいまいちよくわからなかったのでメモです。

結論: **指定した名前のTriggerが呼ばれる**


# おまけ: コード追跡

実際の挙動はButtonコンポーネントの継承元であるSelectableの [`doStateTransition`](https://github.com/Unity-Technologies/uGUI/blob/main/com.unity.ugui/Runtime/UGUI/UI/Core/Selectable.cs#L650-L710) で定義されています。
選択状態に合わせて `m_AnimationTriggers` で指定されたトリガー名を取り出し、それを [`TriggerAnimation`](https://github.com/Unity-Technologies/uGUI/blob/main/com.unity.ugui/Runtime/UGUI/UI/Core/Selectable.cs#L1101-L1115) にて発火させています。
