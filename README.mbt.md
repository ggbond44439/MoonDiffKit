# MoonDiffKit

MoonDiffKit 是一个面向 MoonBit 的文本差异、补丁与变更分析基础库。

项目聚焦 LCS、行级 diff、文本切行、上下文 hunk、统一补丁导出、变更统计、相似度评分和评审摘要，适合代码评审工具、文档协作、配置对比、教学算法示例和命令行工具复用。

本次整改后，MoonDiffKit 已不只是薄薄的 diff 摘要层，而是提供从文本输入到 diff 计算、hunk 分组、patch 输出、apply 验证和 report 汇总的完整闭环。

## 当前能力

- `DiffOp` 表示 `equal`、`add`、`remove` 三类行级操作。
- `DiffStats` 汇总相同行、新增行、删除行和总变更数。
- `DiffHunk` 表示带上下文的 patch hunk，支持 old/new 起点和行数统计。
- `DiffReport` 汇总 hunk 数、增删统计、相似度和可逆性。
- `split_lines` 与 `diff_text` 支持从原始文本直接进入 diff 流程。
- 基于 LCS 的行级差异计算，保持变更顺序稳定。
- 支持完整统一补丁导出和带上下文 hunk 的 patch 导出。
- 支持根据 diff 操作重建新版本，形成生成与应用闭环。
- 提供 LCS 相似度评分，用千分制表达两个版本的接近程度。
- 提供 CLI 演示、CI、Issue 模板和 PR 模板。

## 快速示例

```moonbit nocheck
let old_lines = ["title", "old line", "tail"]
let new_lines = ["title", "new line", "tail", "extra"]
let ops = @MoonDiffKit.diff_lines(old_lines, new_lines)
let stats = @MoonDiffKit.summarize(ops)
let report = @MoonDiffKit.diff_report(old_lines, new_lines, context=1)

println(stats.to_summary())
println(report.to_json())
println(@MoonDiffKit.to_context_patch(ops, context=1))
```

运行演示：

```bash
moon run cmd/main
```

运行测试：

```bash
moon test
```

## 设计原则

1. 核心算法后端中立，不依赖文件系统、浏览器或外部 diff 工具。
2. API 使用 MoonBit 原生结构体与数组，便于工具链、CLI 和教学代码复用。
3. 以确定性测试覆盖每个公开能力，保证后续扩展不会破坏基本语义。

## 仓库

- GitHub: <https://github.com/ggbond44439/MoonDiffKit>
- GitLink: <https://gitlink.org.cn/Chs1375844439/MoonDiffKit.git>

功能清单见 [docs/FEATURES.md](docs/FEATURES.md)。
