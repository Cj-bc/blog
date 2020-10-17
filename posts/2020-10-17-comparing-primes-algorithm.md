---
title: 簡易的な素数探索アルゴリズムの速度比較
tags:
  - python
  - アルゴリズム
kind: memo
date: October 17, 2020
---

いや簡単なものなのですが個人的なメモ。
実行言語は`python 3.7.4`です。

# 比較するアルゴリズム

# 1. 定義通りの求め方

素数は「自分自身と1のみを約数に持つ数」なので、「自分自身と1以外に割り切れる数があるか」を調べれば素数かの判定ができることになります。

```python
def fromDefinition(nums: [int]) -> [int]:
  def f(n: int) -> bool:
    for i in range(1, n):
      if n % i == 0:
        return False
      return True

    return list(filter(f, nums))
```

## エラトステネスの揮

多分中学校かそこらへんで習ったであろう方法。
求めたい範囲の数の集合から、小さい素数の倍数をふるい落としていく方法です。  
[wikipediaの図解](https://ja.wikipedia.org/wiki/%E3%82%A8%E3%83%A9%E3%83%88%E3%82%B9%E3%83%86%E3%83%8D%E3%82%B9%E3%81%AE%E7%AF%A9)がわかりやすい。

```python
import time
from math import sqrt

def eratosthenes(nums: [int]) -> [int]:
    if nums[0] <= 1:
        return eratosthenes(nums[1:])

    head = nums[0]
    if head >= sqrt(nums[-1]):
        return nums

    ret = list(filter(lambda i: i % head != 0, nums))
    return [head] + eratosthenes(ret)
```

# 実行時間計測

それぞれの処理を1000回ずつ実行し、その平均を求めた

## 計測用コード

```python
def mesureTime(f, *args) -> float:
    startTime = time.time()
    f(*args)
    return time.time() - startTime

def mesureTimeAvr(f, *args) -> float:
    t = 0.0
    for _ in range(1000):
        t+=mesureTime(f, *args)
    return t / 1000


x = range(1, 100 + 1)
print(f"fromDefinition: {mesureTimeAvr(fromDefinition, x)}")
print(f"eratosthenes  : {mesureTimeAvr(eratosthenes, x)}")
```

## 結果

```
fromDefinition: 3.378009796142578e-05
eratosthenes  : 2.4552106857299804e-05
```

エラトステネスの揮の方が1秒くらい早い。
Orderはわからん！！
