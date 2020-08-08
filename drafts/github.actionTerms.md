---
title: Github actionsの単語について
keywords:
  - github actions
  - 単語
  - tips
date: August 07, 2020
---

Github Actionsの単語について、公式でまとまっているサイトが[こちら](https://docs.github.com/en/actions/getting-started-with-github-actions/core-concepts-for-github-actions)です


感覚としてはこのような形

```
Runner1
 |-- Job1
      |- step1.1
      |- step1.2
      ...
      |- step1.n
          |-- Action1.n.1
          |-- Action1.n.2
          ...
          |-- Action1.n.m
Runner2
 |-- Job2
```
