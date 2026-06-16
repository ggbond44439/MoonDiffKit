# Changelog

## 0.1.1 - 2026-06-16

- 增加 `DiffHunk`，支持上下文 hunk 起点和行数统计。
- 增加 `DiffReport`，输出 hunk 数、增删统计、相似度和可逆性。
- 增加 `split_lines` 与 `diff_text`，支持从原始文本直接生成 diff。
- 增加 `build_hunks` 和 `to_context_patch`，输出带 hunk header 的上下文补丁。
- 更新 CLI、README 和功能完成说明，回应“仓库内容过于单薄”的初审意见。

## 0.1.0 - 2026-06-11

- 初始化 MoonDiffKit 项目结构和元信息。
- 增加 DiffOp、DiffStats、LCS 长度、行级 diff 和变更统计。
- 增加统一补丁导出、diff 应用、相似度评分和评审摘要。
- 增加 CLI 演示、CI 配置、Issue 模板和 PR 模板。
- 增加 README、路线图、公开开发追踪和示例文档。
