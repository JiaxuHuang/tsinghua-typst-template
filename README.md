# Tsinghua-Typst-Template

一个基于 [Typst](https://github.com/typst/typst) 构建的清华大学（Tsinghua University）幻灯片模板。

本模板基于 `touying` 包的内置 `university` 主题开发，中英文字体分别预设为**华文中宋**与 **Georgia**。

![image](https://github.com/JiaxuHuang/tsinghua-typst-template/blob/main/preview_figures/title.png)
![image](https://github.com/JiaxuHuang/tsinghua-typst-template/blob/main/preview_figures/content.png)

## 模板特色

本模板实现了一系列便捷功能，旨在提升幻灯片制作与演示效率：

* **动态导航栏**：底部自动生成并显示所有一级标题，当前所处章节会高亮显示。
* **便捷跳转**：导航栏中的所有标题均内置超链接，点击即可快速跳转至对应章节的起始页。
* **进度可视化**：顶部配有自动进度条，实时显示当前幻灯片的放映进度。
* **清晰页码**：页面右下角自动显示“当前页码 / 总页码”。
* **自动化目录**：支持一键生成自动编号且内含超链接的目录页 (Table of Contents)。

## 2025-11-10 更新：引入全新样式

受到 [skriptum/Diatypst](https://github.com/skriptum/Diatypst) 项目的启发，本次更新带来了一种全新视觉样式。

* **轻松切换**：只需在文件开头引入 `tsinghua_new.typ` 即可应用新样式。
* **可选版本**：
    * `tsinghua_new.typ`：包含所有功能（含底部导航栏超链接）。
    * `tsinghua_new_no_links.typ`：新版样式，但**移除**了底部导航栏的超链接，提供更简洁的浏览体验。

样式如下所示：
![image](https://github.com/JiaxuHuang/tsinghua-typst-template/blob/main/preview_figures/title2.jpg)
![image](https://github.com/JiaxuHuang/tsinghua-typst-template/blob/main/preview_figures/section2.jpg)
> **为何提供“无链接”版本 (`tsinghua_new_no_links.typ`)？**
> * **兼容性考量**：主要目的是为了优化 PDF 导出 (Export) 为 **PPTX** 后的兼容性。在某些转换工具中，Typst 生成的超链接可能会导致导航栏的**字体颜色发生非预期的变化**。
> * **使用建议**：如果您不需要将 PDF 转换为 PPTX，或者主要在 PDF 环境下演示，**推荐使用原版 `tsinghua_new.typ`** 以保留完整的交互功能。

## 为什么选择 Typst？

Typst 是一种现代、可编程的标记语言，专为科学出版而设计。

* **易于上手**：语法简洁直观。
* **编译神速**：采用增量编译技术，编译速度远超 LaTeX (Beamer)，本机测试几乎可实现实时预览。

欢迎访问 **Typst 中文社区** 了解更多详情：[https://typst-doc-cn.github.io/docs/tutorial/](https://typst-doc-cn.github.io/docs/tutorial/)
