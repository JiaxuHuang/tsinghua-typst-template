#import "@preview/touying:0.6.1": *
#import "themes/tsinghua_new.typ": *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(aspect-ratio: "16-9", config-info(
  title: [汇报],
  subtitle: [Subtitle],
  date: datetime.today(),
  institution: [Institution],
  logo: image("themes/tsinghua.svg", width: 4cm),
))
#set text(font: ("Georgia", "STZhongsong"))
#title-slide(authors: ([Author A], [Author B]))

#toc-slide(left-indent: 5%)

= 研究背景

== hello
hello world@long2018performance 
= 研究问题
#focus-slide[
  Another variant with primary color in background...
]
= 研究方法
==
#lorem(40)
= 研究结果
#matrix-slide[
  left
][
  middle
][
  right
]

#matrix-slide(columns: 1)[
  top
][
  bottom
]


= 结论与展望
== 
#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)

= 参考文献
==

#set text(size: 0.7em) // 调整参考文献的文本大小
#bibliography(title: none, "b.bib", style: "apa")

