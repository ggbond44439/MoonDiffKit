# Line Diff Example

目标：对比两组文本行，生成统计信息和统一补丁风格输出。

```moonbit nocheck
let old_lines = ["title", "old line", "tail"]
let new_lines = ["title", "new line", "tail", "extra"]
let ops = @MoonDiffKit.diff_lines(old_lines, new_lines)

println(@MoonDiffKit.summarize(ops).to_summary())
println(@MoonDiffKit.to_unified_patch(ops))
```

示例输出：

```text
equal=2, added=2, removed=1, changed=3
--- old
+++ new
@@
 title
-old line
+new line
 tail
+extra
```
