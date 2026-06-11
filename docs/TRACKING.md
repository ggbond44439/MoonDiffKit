# MoonDiffKit 公开开发追踪

本文件用于记录比赛阶段的公开开发线索，便于后续在 GitHub / GitLink 上对应提交、工单和合并请求。

## 已完成

- 初始化 MoonBit 包结构和项目元信息。
- 建立 DiffOp / DiffStats 基础模型。
- 实现 LCS 长度和行级 diff。
- 实现统一补丁导出和 diff 应用。
- 实现相似度评分和摘要导出。
- 建立 CLI、CI、Issue 模板、PR 模板和变更记录。

## 建议创建的工单

- `feature: 支持带上下文的 hunk 分组`
- `feature: 增加 unified patch 解析器`
- `feature: 支持忽略空白的 diff 选项`
- `test: 增加大文件 diff 边界测试`

## 建议维护节奏

- 每次新增公开 API 后同步补测试。
- 每个阶段至少更新一次 `CHANGELOG.md`。
- 比赛报名或阶段检查前，手动同步 GitHub 与 GitLink。
