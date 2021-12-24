* pythonのelifはifよりも速いのか
    :PROPERTIES:
    :DATE: [2020-11-07 Sat]
    :TAGS: :python:検証:
    :AUTHOR: Cj-bc
    :BLOG_POST_KIND: Memo
    :BLOG_POST_PROGRESS: Published
    :BLOG_POST_STATUS: Normal
    :END:
一つの変数に対して、複数の条件で分岐させたい時時、大抵は=elif=を使って以下のように書くと思います。

#+begin_src python
  if n == "A":
      ...
  elif n == "B":
      ...
#+end_src

しかし、全ての場合ではありませんがこの場合はif文の羅列で書くこともできます。

#+begin_src python
  if n == "A":
      ...
  if n == "B":
      ...
#+end_src

直感的に、nの値によってはelifの方がif文の実行回数が少なくなるため速そうに思えますが、本当にそうなのか気になったので試してみます。

** tl;dr
   :PROPERTIES:
   :CUSTOM_ID: tldr
   :END:
速いぽい

** 条件
   :PROPERTIES:
   :CUSTOM_ID: 条件
   :END:
pythonは3.7.4、if文の中身が同じものだと最適化がかかったりしないか怖かったのでそれぞれ違う出力をするprint文を入れます。
elifの数は適当に多めにしておきました。
また、1000回実行した平均の速度を表示するようにしました。

** 測定に使ったコード
   :PROPERTIES:
   :CUSTOM_ID: 測定に使ったコード
   :END:
長いので

#+begin_html
  <details>
#+end_html

#+begin_html
  <summary>
#+end_html

測定コード

#+begin_html
  </summary>
#+end_html

#+begin_example
  import time

  a = 100

  # without elif {{{
  def f_without_elif():
      if a < 10:
          print("10")
      if 10 <= a < 20:
          print("20")
      if 20 <= a < 30:
          print("30")
      if 30 <= a < 40:
          print("40")
      if 40 <= a < 50:
          print("50")
      if 50 <= a < 60:
          print("60")
      if 60 <= a < 70:
          print("70")
      if 70 <= a < 80:
          print("80")
      if 80 <= a < 90:
          print("90")
      if 90 <= a < 100:
          print("100")
      if 100 <= a < 110:
          print("110")
      if 110 <= a < 120:
          print("120")
      if 120 <= a < 130:
          print("130")
      if 130 <= a < 140:
          print("140")
      if 140 <= a < 150:
          print("150")
      if 150 <= a < 160:
          print("160")
      if 160 <= a < 170:
          print("170")
      if 170 <= a < 180:
          print("180")
      if 180 <= a < 190:
          print("190")
      if 190 <= a < 200:
          print("200")
      if 200 <= a < 210:
          print("210")
      if 210 <= a < 220:
          print("220")
      if 220 <= a < 230:
          print("230")
      if 230 <= a < 240:
          print("240")
      if 240 <= a < 250:
          print("250")
      if 250 <= a < 260:
          print("260")
      if 260 <= a < 270:
          print("270")
      if 270 <= a < 280:
          print("280")
      if 280 <= a < 290:
          print("290")
      if 290 <= a < 300:
          print("300")
      if 300 <= a < 310:
          print("310")
      if 310 <= a < 320:
          print("320")
      if 320 <= a < 330:
          print("330")
      if 330 <= a < 340:
          print("340")
      if 340 <= a < 350:
          print("350")
      if 350 <= a < 360:
          print("360")
      if 360 <= a < 370:
          print("370")
      if 370 <= a < 380:
          print("380")
      if 380 <= a < 390:
          print("390")
      if 390 <= a < 400:
          print("400")
      if 400 <= a < 410:
          print("410")
      if 410 <= a < 420:
          print("420")
      if 420 <= a < 430:
          print("430")
      if 430 <= a < 440:
          print("440")
      if 440 <= a < 450:
          print("450")
      if 450 <= a < 460:
          print("460")
      if 460 <= a < 470:
          print("470")
      if 470 <= a < 480:
          print("480")
      if 480 <= a < 490:
          print("490")
      if 490 <= a < 500:
          print("500")
      if 500 <= a < 510:
          print("510")
      if 510 <= a < 520:
          print("520")
      if 520 <= a < 530:
          print("530")
      if 530 <= a < 540:
          print("540")
      if 540 <= a < 550:
          print("550")
      if 550 <= a < 560:
          print("560")
      if 560 <= a < 570:
          print("570")
      if 570 <= a < 580:
          print("580")
      if 580 <= a < 590:
          print("590")
      if 590 <= a < 600:
          print("600")
      if 600 <= a < 610:
          print("610")
      if 610 <= a < 620:
          print("620")
      if 620 <= a < 630:
          print("630")
      if 630 <= a < 640:
          print("640")
      if 640 <= a < 650:
          print("650")
      if 650 <= a < 660:
          print("660")
      if 660 <= a < 670:
          print("670")
      if 670 <= a < 680:
          print("680")
      if 680 <= a < 690:
          print("690")
      if 690 <= a < 700:
          print("700")
      if 700 <= a < 710:
          print("710")
      if 710 <= a < 720:
          print("720")
      if 720 <= a < 730:
          print("730")
      if 730 <= a < 740:
          print("740")
      if 740 <= a < 750:
          print("750")
      if 750 <= a < 760:
          print("760")
      if 760 <= a < 770:
          print("770")
      if 770 <= a < 780:
          print("780")
      if 780 <= a < 790:
          print("790")
      if 790 <= a < 800:
          print("800")
      if 800 <= a < 810:
          print("810")
      if 810 <= a < 820:
          print("820")
      if 820 <= a < 830:
          print("830")
      if 830 <= a < 840:
          print("840")
      if 840 <= a < 850:
          print("850")
      if 850 <= a < 860:
          print("860")
      if 860 <= a < 870:
          print("870")
      if 870 <= a < 880:
          print("880")
      if 880 <= a < 890:
          print("890")
      if 890 <= a < 900:
          print("900")
      if 900 <= a < 910:
          print("910")
      if 910 <= a < 920:
          print("920")
      if 920 <= a < 930:
          print("930")
      if 930 <= a < 940:
          print("940")
      if 940 <= a < 950:
          print("950")
      if 950 <= a < 960:
          print("960")
      if 960 <= a < 970:
          print("970")
      if 970 <= a < 980:
          print("980")
      if 980 <= a < 990:
          print("990")
      if 990 <= a < 1000:
          print("1000")
      if 1000 <= a < 1010:
          print("1010")
      if 1010 <= a < 1020:
          print("1020")
      if 1020 <= a < 1030:
          print("1030")
      if 1030 <= a < 1040:
          print("1040")
      if 1040 <= a < 1050:
          print("1050")
      if 1050 <= a < 1060:
          print("1060")
      if 1060 <= a < 1070:
          print("1070")
  # }}}


  # with elif {{{
  def f_with_elif():
      if a < 10:
          print("10")
      elif 10 <= a < 20:
          print("20")
      elif 20 <= a < 30:
          print("30")
      elif 30 <= a < 40:
          print("40")
      elif 40 <= a < 50:
          print("50")
      elif 50 <= a < 60:
          print("60")
      elif 60 <= a < 70:
          print("70")
      elif 70 <= a < 80:
          print("80")
      elif 80 <= a < 90:
          print("90")
      elif 90 <= a < 100:
          print("100")
      elif 100 <= a < 110:
          print("110")
      elif 110 <= a < 120:
          print("120")
      elif 120 <= a < 130:
          print("130")
      elif 130 <= a < 140:
          print("140")
      elif 140 <= a < 150:
          print("150")
      elif 150 <= a < 160:
          print("160")
      elif 160 <= a < 170:
          print("170")
      elif 170 <= a < 180:
          print("180")
      elif 180 <= a < 190:
          print("190")
      elif 190 <= a < 200:
          print("200")
      elif 200 <= a < 210:
          print("210")
      elif 210 <= a < 220:
          print("220")
      elif 220 <= a < 230:
          print("230")
      elif 230 <= a < 240:
          print("240")
      elif 240 <= a < 250:
          print("250")
      elif 250 <= a < 260:
          print("260")
      elif 260 <= a < 270:
          print("270")
      elif 270 <= a < 280:
          print("280")
      elif 280 <= a < 290:
          print("290")
      elif 290 <= a < 300:
          print("300")
      elif 300 <= a < 310:
          print("310")
      elif 310 <= a < 320:
          print("320")
      elif 320 <= a < 330:
          print("330")
      elif 330 <= a < 340:
          print("340")
      elif 340 <= a < 350:
          print("350")
      elif 350 <= a < 360:
          print("360")
      elif 360 <= a < 370:
          print("370")
      elif 370 <= a < 380:
          print("380")
      elif 380 <= a < 390:
          print("390")
      elif 390 <= a < 400:
          print("400")
      elif 400 <= a < 410:
          print("410")
      elif 410 <= a < 420:
          print("420")
      elif 420 <= a < 430:
          print("430")
      elif 430 <= a < 440:
          print("440")
      elif 440 <= a < 450:
          print("450")
      elif 450 <= a < 460:
          print("460")
      elif 460 <= a < 470:
          print("470")
      elif 470 <= a < 480:
          print("480")
      elif 480 <= a < 490:
          print("490")
      elif 490 <= a < 500:
          print("500")
      elif 500 <= a < 510:
          print("510")
      elif 510 <= a < 520:
          print("520")
      elif 520 <= a < 530:
          print("530")
      elif 530 <= a < 540:
          print("540")
      elif 540 <= a < 550:
          print("550")
      elif 550 <= a < 560:
          print("560")
      elif 560 <= a < 570:
          print("570")
      elif 570 <= a < 580:
          print("580")
      elif 580 <= a < 590:
          print("590")
      elif 590 <= a < 600:
          print("600")
      elif 600 <= a < 610:
          print("610")
      elif 610 <= a < 620:
          print("620")
      elif 620 <= a < 630:
          print("630")
      elif 630 <= a < 640:
          print("640")
      elif 640 <= a < 650:
          print("650")
      elif 650 <= a < 660:
          print("660")
      elif 660 <= a < 670:
          print("670")
      elif 670 <= a < 680:
          print("680")
      elif 680 <= a < 690:
          print("690")
      elif 690 <= a < 700:
          print("700")
      elif 700 <= a < 710:
          print("710")
      elif 710 <= a < 720:
          print("720")
      elif 720 <= a < 730:
          print("730")
      elif 730 <= a < 740:
          print("740")
      elif 740 <= a < 750:
          print("750")
      elif 750 <= a < 760:
          print("760")
      elif 760 <= a < 770:
          print("770")
      elif 770 <= a < 780:
          print("780")
      elif 780 <= a < 790:
          print("790")
      elif 790 <= a < 800:
          print("800")
      elif 800 <= a < 810:
          print("810")
      elif 810 <= a < 820:
          print("820")
      elif 820 <= a < 830:
          print("830")
      elif 830 <= a < 840:
          print("840")
      elif 840 <= a < 850:
          print("850")
      elif 850 <= a < 860:
          print("860")
      elif 860 <= a < 870:
          print("870")
      elif 870 <= a < 880:
          print("880")
      elif 880 <= a < 890:
          print("890")
      elif 890 <= a < 900:
          print("900")
      elif 900 <= a < 910:
          print("910")
      elif 910 <= a < 920:
          print("920")
      elif 920 <= a < 930:
          print("930")
      elif 930 <= a < 940:
          print("940")
      elif 940 <= a < 950:
          print("950")
      elif 950 <= a < 960:
          print("960")
      elif 960 <= a < 970:
          print("970")
      elif 970 <= a < 980:
          print("980")
      elif 980 <= a < 990:
          print("990")
      elif 990 <= a < 1000:
          print("1000")
      elif 1000 <= a < 1010:
          print("1010")
      elif 1010 <= a < 1020:
          print("1020")
      elif 1020 <= a < 1030:
          print("1030")
      elif 1030 <= a < 1040:
          print("1040")
      elif 1040 <= a < 1050:
          print("1050")
      elif 1050 <= a < 1060:
          print("1060")
      elif 1060 <= a < 1070:
          print("1070")
  # }}}



  t_start = time.time()
  for _ in range(1000):
      f_without_elif()
  t_end   = time.time()
  print(f"without elif: {(t_end - t_start)/1000} sec")

  t_with_elif_start = time.time()
  for _ in range(1000):
      f_with_elif()
  t_with_elif_end   = time.time()
  print(f"with elif   : {(t_with_elif_end - t_with_elif_start)/1000} sec")
#+end_example

#+begin_html
  </details>
#+end_html

** 結果
   :PROPERTIES:
   :CUSTOM_ID: 結果
   :END:
=print=でたくさん標準出力を使っていますが、 そこの値は重要ではないので
私は[[https://github.com/thinca/vim-quickrun][quickrun]]を使って
vim上のバッファで加工して消しています

#+begin_example
  without elif: 4.281997680664063e-06 sec
  with elif   : 9.88006591796875e-07 sec
#+end_example

一瞬遅くなって見えますが、桁が一桁違います。少数表記にすると

#+begin_example
  without elif: 0.000004 sec
  with elif   : 0.000001 sec
#+end_example

となり、=elif=の方が速いことがわかります。

** 考察
   :PROPERTIES:
   :CUSTOM_ID: 考察
   :END:
なぜ速いのかを考えてみます。

*** 構文木
    :PROPERTIES:
    :CUSTOM_ID: 構文木
    :END:
=elif=には特別なノードがなく、構文木に落とすと親の=If=ノードの=oreelse=に含まれる=If=ノードになります。

#+begin_src python
  import ast

  print(ast.dump(ast.parse("""
  if x:
     ...
  elif y:
     ...
  else:
     ...

  if z:
      ...
  """)))
#+end_src

#+begin_example
  Module(
      body=[
          If(test=Name(id='x', ctx=Load()),
             body=[Expr(value=Ellipsis())],
             orelse=[
                If(test=Name(id='y', ctx=Load()),
                   body=[Expr(value=Ellipsis())],
                   orelse=[Expr(value=Ellipsis())])
                ]
            ),
          If(test=Name(id='z', ctx=Load()),
             body=[Expr(value=Ellipsis())],
             orelse=[])
          ]
  )
#+end_example

https://docs.python.org/ja/3/library/ast.html?highlight=elif#ast.If

*** ステップ数を調べる
    :PROPERTIES:
    :CUSTOM_ID: ステップ数を調べる
    :END:
おそらく、if文が実行される回数が少ないはず、なのでpythonのデバッガである[[https://docs.python.org/3/library/pdb.html][pdb]]を使って調べてみます。

#+begin_example
  >>> # まずはelif使わないもの
  >>> pdb.run("""
      ... if True:
      ...     print("s")
      ... if False:
      ...     print("f")
      ... """)
  > <string>(3)<module>()->None
  (Pdb) n
  s
  > <string>(4)<module>()->None
  (Pdb)
  --Return--
  > <string>(4)<module>()->None
  (Pdb)
  >>> pdb.run("""
      ... if True:
      ...     print("s")
      ... elif False:
      ...     print("f")
      ... """)
  > <string>(3)<module>()->None
  (Pdb) n
  s
  --Return--
  > <string>(3)<module>()->None
  (Pdb)
  >>>
#+end_example

やはり、=if=文を分割した場合と比べて=elif=の方が”--Return--“が早く来ていますね。
これひとつではそこまで差異はないと思いますが、もっと複雑な条件式を使っている場合や何度も重なっている場合は影響が出そうですね。
