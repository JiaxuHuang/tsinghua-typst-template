// University theme

// Originally contributed by Pol Dellaiera - https://github.com/drupol

#import "@preview/touying:0.6.1": *

// 定义全局状态变量来跟踪当前章节编号
#let current-section-number = state("current-section-number", 1)

/// Default slide function for the presentation.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - repeat (int, auto): is the number of subslides. The default is `auto`, allowing touying to automatically calculate the number of subslides. The `repeat` argument is required when using `#slide(repeat: 3, self => [ .. ])` style code to create a slide, as touying cannot automatically detect callback-style `uncover` and `only`.
///
/// - setting (dictionary): is the setting of the slide, which can be used to apply set/show rules for the slide.
///
/// - composer (array, function): is the layout composer of the slide, allowing you to define the slide layout.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 1fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (arguments): is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
///
#let slide(config: (:), repeat: auto, setting: body => body, composer: auto, align: auto, ..bodies) = touying-slide-wrapper(
  self => {
    if align != auto {
      self.store.align = align
    }
    let header(self) = {
      set std.align(top)
      grid(rows: (auto, auto), row-gutter: 3mm, if self.store.progress-bar {
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.tertiary)
      }, block(inset: (x: .5em), components.left-and-right(
        text(fill: self.colors.primary, weight: "bold", size: 1.2em, utils.call-or-display(self, self.store.header)),
        text(fill: self.colors.primary.lighten(65%), utils.call-or-display(self, self.store.header-right)),
      )))
    }
    let footer(self) = {
      set std.align(center + bottom)
      set text(size: 0.7em)

      // 直接调用 footer-b，去掉 footer-a 和 footer-c
      utils.call-or-display(self, self.store.footer-b)
    }
    let self = utils.merge-dicts(self, config-page(header: header, footer: footer))
    let new-setting = body => {
      show: std.align.with(self.store.align)
      show: setting
      body
    }
    touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
  },
)

/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - extra (string, none): is the extra information for the slide. This can be passed to the `title-slide` function to display additional information on the title slide.
// #let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
//   self = utils.merge-dicts(self, config, config-common(freeze-slide-counter: true))
//   let info = self.info + args.named()
//   info.authors = {
//     let authors = if "authors" in info {
//       info.authors
//     } else {
//       info.author
//     }
//     if type(authors) == array {
//       authors
//     } else {
//       (authors,)
//     }
//   }
//   let body = {
//     std.align(center + horizon, {
//       // 标题部分放在顶部
//       block(inset: 0em, breakable: false, {
//         text(size: 2em, fill: self.colors.primary, strong(info.title))
//         if info.subtitle != none {
//           parbreak()
//           text(size: 1.2em, fill: self.colors.primary, info.subtitle)
//         }
//       })

//       // 添加垂直间距
//       v(0em)

//       // Logo部分放在中间
//       if info.logo != none {
//         block(width: 100%, align(center, text(fill: self.colors.primary, info.logo)))
//       }

//       // 添加垂直间距
//       v(0em)

//       // 作者信息放在底部
//       set text(size: 1em)
//       grid(
//         columns: (1fr,) * calc.min(info.authors.len(), 3),
//         column-gutter: 1em,
//         row-gutter: 1em,
//         ..info.authors.map(author => text(fill: self.colors.neutral-darkest, author)),
//       )

//       if info.institution != none {
//         v(.5em)
//         text(size: .9em, info.institution)
//       }

//       if info.date != none {
//         v(.5em)
//         text(size: .8em, utils.display-info-date(self))
//       }
//     })
//   }
//   touying-slide(self: self, body)
// })

/// 辅助函数：从内容中提取文本，处理复杂标题
#let extract-text-from-content(content) = {
  if content == none { return "" }

  if type(content) == str {
    return content
  } else if content.has("text") {
    return content.text
  } else if content.has("body") {
    return extract-text-from-content(content.body)
  } else if content.has("children") {
    return content.children.map(extract-text-from-content).join("")
  } else {
    return str(content)
  }
}

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - level (int, none): is the level of the heading.
///
/// - numbered (boolean): is whether the heading is numbered.
///
/// - body (auto): is the body of the section. This will be passed automatically by Touying.
///
// 确保我们已经定义了状态变量
#let current-section-number = state("current-section-number", 0)
#set heading(numbering: "1.")

#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  sidebar-fill: auto,
  sidebar-content: image("logo2.svg", width: 40%),
  sidebar-width: 20%,
  body,
) = touying-slide-wrapper(self => {
  // 获取当前标题文本
  let current-heading = utils.display-current-heading(level: level, numbered: numbered)

  // 更新章节编号
  let section-num = 0
  current-section-number.update(old => {
    if level == 1 {
      // 只对一级标题递增
      section-num = old + 1
      old + 1
    } else {
      section-num = old
      old
    }
  })

  // 为章节幻灯片创建唯一标签
  let section-label-name = "section-" + str(section-num)

  let sidebar-bg = if sidebar-fill == auto { self.colors.primary } else { sidebar-fill }

  // 原有的幻灯片内容（右侧部分）
  let right-content = {
    set std.align(horizon)
    show: pad.with(left: 10%, right: 10%)

    // 移除这里的全局文本设置，改为分别设置标题和正文
    // set text(size: 1.5em, fill: self.colors.primary, weight: "bold")

    // 先放置标签，确保标签被正确添加到页面顶部
    stack(
      dir: ttb,
      spacing: .65em,
      // 只对标题应用大字体和粗体
      text(size: 2em, fill: self.colors.primary, weight: "bold", current-heading),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light),
      ),
    )

    // 正文使用适当的字体大小
    set text(size: 1.2em)
    body
  }

  // 组合成新的幻灯片主体
  let slide-body = {
    grid(
      columns: (sidebar-width, 1fr),
      rows: (100%),
      gutter: 0pt,
      // 左侧色块
      block(width: 100%, height: 100%, fill: sidebar-bg, inset: 0pt, align(center + horizon, sidebar-content)),
      // 右侧内容
      block(width: 100%, height: 100%, right-content),
    )
  }

  touying-slide(self: self, config: config-page(header: none, footer: none, margin: 0em), slide-body)
})

/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - background-color (color, none): is the background color of the slide. Default is the primary color.
///
/// - background-img (string, none): is the background image of the slide. Default is none.
#let focus-slide(config: (:), background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(margin: 1em, ..args))
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, std.align(horizon, body))
})

/// 创建目录幻灯片
///
/// 此功能自动从文档中提取一级标题，并创建一个目录页面
///
/// - config (dictionary): 幻灯片配置
/// - title (content): 目录页的标题，默认为"目录"
/// - title-color (color): 标题颜色，默认为主题的 primary 颜色
/// - title-size (length): 标题大小，默认为 1.5em
/// - item-size (length): 目录项大小，默认为 1.1em
/// - spacing (length): 项目间距，默认为 0.8em
/// - left-indent (length): 左侧缩进，默认为 12%
///
#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  // --- 数据准备部分保持不变 ---
  self = utils.merge-dicts(self, config, config-common(freeze-slide-counter: true))
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }

  // --- 全新的、精确的 50/50 布局 ---
  let body = {
    // 顶部区块：严格占据 50% 高度
    block(
      width: 100%,
      height: 50%,
      fill: self.colors.primary, // 设置背景为主题色
      inset: (x: 4%, bottom: 2.5em), // 设置内边距，让文字离开边缘
      align(bottom + left)[ // 将内容对齐到此区块的左下角
        #text(2em, weight: "bold", fill: self.colors.neutral-lightest, info.title) ],
    )

    // 底部区块：占据剩下的 50% 高度
    // 底部区块：占据剩下的高度
    // 底部区块
    // 底部区块
    block(width: 100%, height: 44%, inset: (x: 4%, top: 0em, bottom: 2.5em), {
      // 使用 grid 布局来垂直居中整行内容
      grid(
        columns: (auto, 1fr),
        align: center, // 垂直居中
        // --- 1. 左侧内容：文字堆叠 ---
        // 使用 place(left, ...) 强制将 stack 容器靠左对齐
        align(
          // align here controls the whole stack
          // and the contents of the stack
          top + left,
          stack(dir: ttb, spacing: 0.8em, if info.subtitle != none {
            text(2em, weight: "bold", fill: self.colors.primary, info.subtitle)
          }, ..info.authors.map(author => text(1.5em, weight: "medium", author)), if info.institution != none {
            text(1em, info.institution)
          }, if info.date != none {
            text(1em, utils.display-info-date(self))
          }),
        ),
        // --- 2. 右侧内容：Logo ---
        // Logo 保持靠右对齐
        if info.logo != none {
          place(right, info.logo)
        },
      )
    })
  }

  // 使用 config-page 创建一个干净的全屏页面
  touying-slide(self: self, config: config-page(header: none, footer: none, margin: 0em), body)
})
#let toc-slide(
  config: (:),
  title: [目录],
  title-color: 1.8em,
  title-size: 2em,
  item-size: 1.5em,
  spacing: 0.8em,
  vspace: 3em,
  left-indent: 20%, // 左侧缩进控制
  sidebar-fill: auto,
  sidebar-content: image("../themes/logo2.svg", width: 40%), // 新增：左侧色块中的内容 (例如 logo)
  sidebar-width: 20%, // 左侧色块宽度
) = touying-slide-wrapper(
  self => {
    self = utils.merge-dicts(self, config, config-common(freeze-slide-counter: true))

    let title-fill = if title-color == auto { self.colors.primary } else { title-color }
    let sidebar-bg = if sidebar-fill == auto { self.colors.primary } else { sidebar-fill }
    let toc-body = {
      grid(
        columns: (sidebar-width, 2fr),
        rows: (100%),
        gutter: 0pt,
        block(width: 100%, height: 100%, fill: sidebar-bg, inset: 0pt, align(center + horizon, sidebar-content)),
        block(
          width: 100%,
          height: 100%,
          {
            pad(
              left: left-indent,
              {
                // v(spacing)
                //
                // 使用 context 和 query 自动获取文档中的一级标题
                context {
                  let all-headings = query(heading.where(level: 1, outlined: true))

                  if all-headings.len() > 0 {
                    // 不再使用外部计数器，而是使用 enumerate() 来获取索引
                    let items = all-headings
                    .enumerate()
                    .map(pair => {
                      let (index, heading) = pair
                      let count = index + 1 // 索引从0开始，所以加1
                      let title-text = extract-text-from-content(heading.body)

                      // 创建带计数器的条目
                      block(width: 100%, inset: (bottom: spacing), {
                        // 添加计数器和标题文本
                        text(fill: self.colors.primary, weight: "medium", str(count) + ". " + link(heading.location(), title-text))
                      })
                    })
                    // set text(size: item-size)
                    // 展示生成的条目列表
                    let content-group = stack(
                      dir: ttb, // 整体方向为从上到下
                      // --- 元素1：独立设置样式的标题 ---
                      // 样式只作用于 title，不会影响其他部分
                      text(size: title-size, fill: self.colors.primary, weight: "bold", title),
                      // --- 元素2：标题和列表之间的垂直间距 ---
                      // 使用 v() 来精确控制标题下方的间距
                      v(vspace), // 你可以把这里的固定值换成 `spacing` 变量
                      // --- 元素3：原来包含 items 的 stack ---
                      // 这个 stack 负责处理目录条目之间的间距和排列
                      block({
                        // 在这个 block 内部，我们为所有后续内容设置了新的默认文本大小
                        set text(size: item-size)

                        // 现在，这个 stack 及其中的所有 `items` 都会自动应用 `item_size`
                        stack(dir: ttb, spacing: spacing, ..items)
                      }),
                    )

                    align(left + horizon, content-group)
                  }
                }
              },
            )
          },
        ),
      )
    }

    touying-slide(self: self, config: config-page(header: none, footer: none, margin: 0em), toc-body)
  },
)

// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#matrix-slide[...][...]` stacks horizontally and `#matrix-slide(columns: 1)[...][...]` stacks vertically.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
#let matrix-slide(config: (:), columns: none, rows: none, ..bodies) = touying-slide-wrapper(
  self => {
    self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(margin: 0em))
    touying-slide(self: self, config: config, composer: components.checkerboard.with(columns: columns, rows: rows), ..bodies)
  },
)

#let university-theme(
  aspect-ratio: "16-9",
  align: top,
  progress-bar: true,
  // 新增参数：文档中所有一级标题的列表
  header: utils.display-current-heading(level: 2, style: auto),
  header-right: self => {
    table(
      columns: (auto, auto),
      inset: 2pt,
      stroke: none,
      align: center + horizon,
      box(utils.display-current-heading(level: 1)),
      h(.3em),
    )
  },
  footer-columns: (0%, 1fr, 25%),
  // 修改 footer-b 显示所有章节标题的表格
  footer-b: self => {
    // 单元格样式，添加链接功能，使用标题的 location 作为链接目标
    // 单元格样式，添加链接功能，使用标题的 location 作为链接目标
    let cell(fill, content, location-target: none) = {
      let cell-content = text(size: 1em, fill: if fill == self.colors.tertiary {
        self.colors.neutral-lightest
      } else {
        self.colors.neutral-lightest.darken(20%)
      }, weight: if fill == self.colors.tertiary { "bold" } else { "regular" }, content)

      // 如果提供了位置目标，创建指向该位置的链接
      let final-content = if location-target != none {
        link(location-target, cell-content)
      } else {
        cell-content
      }

      box(
        width: 100%,
        height: 100%,
        fill: fill,
        radius: 0pt,
        stroke: white,
        inset: 4pt,
        std.align(center + horizon, final-content),
      )
    }

    // 使用高级查询方法从文档中获取标题
    context {
      // 获取当前位置
      let current-loc = here()

      // 创建一个选择器来获取标题
      let all-headings = query(heading.where(level: 1, outlined: true))

      // 如果没有找到标题，使用默认列表
      let section-list = if all-headings.len() > 0 {
        all-headings
      } else if "section-list" in self.info {
        self.info.section-list
      } else {
        // 默认情况下，创建空列表
        ()
      }

      // 找出当前章节
      let current-section-index = 0

      // 查找当前页之前或当前页的所有标题
      let headings-before = query(selector(heading.where(level: 1, outlined: true)).before(current-loc))

      if headings-before.len() > 0 {
        // 获取最后一个在当前位置之前的标题
        let last-heading = headings-before.last()

        // 查找此标题在所有标题列表中的位置
        for (i, heading) in all-headings.enumerate() {
          if heading.location() == last-heading.location() {
            current-section-index = i
            break
          }
        }
      }

      // 生成页脚
      block(width: 100%, height: 100%, fill: self.colors.primary, {
        grid(
          columns: (1fr,) * section-list.len() + (0.7fr,), // 添加一列用于显示页码
          rows: (1fr,),
          gutter: 0pt,
          stroke: white,
          // 章节标题部分，添加超链接到各自的位置
          ..all-headings
          .enumerate()
          .map(pair => {
            let (index, heading) = pair
            let is-current = index == current-section-index

            // 获取标题内容
            let title-text = extract-text-from-content(heading.body)

            // 使用标题的 location() 作为链接目标
            cell(
              if is-current { self.colors.tertiary } else { self.colors.primary },
              title-text,
              location-target: if is-current { none } else { heading.location() },
            )
          }),
          // 添加页码
          cell(self.colors.primary, text(size: 0.9em, fill: self.colors.neutral-lightest, weight: "regular", {
            h(1fr)
            utils.slide-counter.display() + " / " + utils.last-slide-number
            h(1fr)
          })),
        )
      })
    }
  },
  ..args,
  body,
) = {
  // 其余部分保持不变
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 2em),
    ),
    config-common(slide-fn: slide, new-section-slide-fn: new-section-slide),
    config-methods(init: (self: none, body) => {
      set text(size: 20pt)
      show heading.where(level: 3): set text(fill: self.colors.primary)
      show heading.where(level: 4): set text(fill: self.colors.primary)

      body
    }, alert: utils.alert-with-primary-color),
    config-colors(
      primary: rgb("#660874"),
      secondary: rgb("#8B008B"),
      tertiary: rgb("#DB7093"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // 保存参数到store，添加section-list
    config-store(
      align: align,
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-b: footer-b,
    ),
    ..args,
  )

  body
}
