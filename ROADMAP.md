# MoonDiffKit Roadmap

## 0.1.x 基础稳定期

- 完成 LCS、行级 diff、统一补丁导出和变更统计。
- 保持 CLI 演示、README、CHANGELOG 和协作模板完整。
- 用确定性测试覆盖公开 API 的典型路径和边界路径。

## 0.2.x Patch 能力增强

- 增加带上下文行数的 hunk 生成。
- 增加 patch 解析和冲突检测。
- 增加忽略空白、忽略大小写等 diff 选项。

## 0.3.x Review 分析

- 增加文件级变更摘要。
- 增加改动规模评估和风险提示。
- 增加 Markdown / JSON 报告导出。

## 长期方向

- 保持核心库零平台依赖。
- 增加 benchmark，比较不同输入规模下的性能。
- 沉淀为 MoonBit 文本处理和代码协作工具的基础组件。
