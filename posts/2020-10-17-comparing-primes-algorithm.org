* 簡易的な素数探索アルゴリズムの速度比較
    :PROPERTIES:
    :DATE: [2020-10-17 Sat]
    :TAGS: :python:アルゴリズム:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
いや簡単なものなのですが個人的なメモ。 実行言語は=python 3.7.4=です。

** 比較するアルゴリズム
   :PROPERTIES:
   :CUSTOM_ID: 比較するアルゴリズム
   :END:
** 1. 定義通りの求め方
   :PROPERTIES:
   :CUSTOM_ID: 定義通りの求め方
   :END:
素数は「自分自身と1のみを約数に持つ数」なので、「自分自身と1以外に割り切れる数があるか」を調べれば素数かの判定ができることになります。

#+begin_src python
  def fromDefinition(nums: [int]) -> [int]:
    def f(n: int) -> bool:
      for i in range(1, n):
        if n % i == 0:
          return False
        return True

      return list(filter(f, nums))
#+end_src

*** エラトステネスの揮
    :PROPERTIES:
    :CUSTOM_ID: エラトステネスの揮
    :END:
多分中学校かそこらへんで習ったであろう方法。
求めたい範囲の数の集合から、小さい素数の倍数をふるい落としていく方法です。\\
[[https://ja.wikipedia.org/wiki/%E3%82%A8%E3%83%A9%E3%83%88%E3%82%B9%E3%83%86%E3%83%8D%E3%82%B9%E3%81%AE%E7%AF%A9][wikipediaの図解]]がわかりやすい。

#+begin_src python
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
#+end_src

** 実行時間計測
   :PROPERTIES:
   :CUSTOM_ID: 実行時間計測
   :END:
それぞれの処理を1000回ずつ実行し、その平均を求めた

*** 計測用コード
    :PROPERTIES:
    :CUSTOM_ID: 計測用コード
    :END:
#+begin_src python
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
#+end_src

*** 結果
    :PROPERTIES:
    :CUSTOM_ID: 結果
    :END:
#+begin_example
  fromDefinition: 3.378009796142578e-05
  eratosthenes  : 2.4552106857299804e-05
#+end_example

エラトステネスの揮の方が1秒くらい早い。 Orderはわからん！！
