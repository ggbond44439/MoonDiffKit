# MoonDiffKit 功能完成说明

## 已完成的特定功能

MoonDiffKit 已经完成从文本差异计算到补丁输出的基础闭环：

1. 文本切行：`split_lines` 将原始文本拆成行数组。
2. 文本 diff：`diff_text` 从两个文本字符串直接生成差异操作。
3. LCS 基线：`lcs_length` 用动态规划计算最长公共子序列长度。
4. 行级 diff：`diff_lines` 生成稳定有序的 `equal`、`add`、`remove` 操作。
5. 变更统计：`summarize` 输出相同行、新增行、删除行和总变更数。
6. patch 导出：`to_unified_patch` 输出基础统一补丁。
7. 上下文 hunk：`build_hunks` 生成带上下文的 `DiffHunk`。
8. 上下文 patch：`to_context_patch` 输出包含 hunk header 的补丁。
9. patch 应用：`apply_ops` 根据 diff 操作重建新版本。
10. 相似度评分：`similarity_per_mille` 用千分制表达两个版本接近程度。
11. 报告汇总：`diff_report` 输出 hunk 数、统计、相似度和可逆性。
12. CLI 演示：`moon run cmd/main` 输出摘要、report JSON 和 context patch。

## 项目边界

本项目不是完整 Git patch 系统，也不依赖外部 diff 工具。当前阶段重点是提供 MoonBit 原生、可测试、可复用的文本 diff 基础组件。

## 后续计划

- 增加 unified patch 解析器。
- 增加忽略空白、忽略大小写等 diff 选项。
- 增加更完整的多 hunk 分组策略。
- 增加大文件 diff benchmark 和随机回归测试。
