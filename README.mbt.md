# MoonDiffKit

MoonDiffKit 是一个面向 MoonBit 的文本差异、补丁与变更分析基础库。

项目聚焦 LCS、行级 diff、统一补丁导出、变更统计、相似度评分和评审摘要，适合代码评审工具、文档协作、配置对比、教学算法示例和命令行工具复用。

## 当前能力

- `DiffOp` 表示 `equal`、`add`、`remove` 三类行级操作。
- `DiffStats` 汇总相同行、新增行、删除行和总变更数。
- 基于 LCS 的行级差异计算，保持变更顺序稳定。
- 统一补丁风格导出，便于接入 review、文档和 CLI 场景。
- 支持根据 diff 操作重建新版本，形成生成与应用闭环。
- 提供 LCS 相似度评分，用千分制表达两个版本的接近程度。
- 提供 CLI 演示、CI、Issue 模板和 PR 模板。

## 快速示例

```moonbit nocheck
let old_lines = ["title", "old line", "tail"]
let new_lines = ["title", "new line", "tail", "extra"]
let ops = @MoonDiffKit.diff_lines(old_lines, new_lines)
let stats = @MoonDiffKit.summarize(ops)

println(stats.to_summary())
println(@MoonDiffKit.to_unified_patch(ops))
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
- GitLink: 待从 GitHub 导入后填写
