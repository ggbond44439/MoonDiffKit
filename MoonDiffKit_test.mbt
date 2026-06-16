///|
test "diff operations expose stable constructors" {
  let same = @MoonDiffKit.DiffOp::equal(0, 0, "alpha")
  let added = @MoonDiffKit.DiffOp::add(1, "beta")
  let removed = @MoonDiffKit.DiffOp::remove(2, "gamma")
  assert_eq(same.kind, "equal")
  assert_eq(added.old_index, -1)
  assert_eq(removed.new_index, -1)
  assert_false(same.is_change())
  assert_true(added.is_change())
}

///|
test "empty stats start from zero" {
  let stats = @MoonDiffKit.DiffStats::empty()
  assert_eq(stats.equal, 0)
  assert_eq(stats.added, 0)
  assert_eq(stats.removed, 0)
  assert_eq(stats.changed, 0)
}

///|
test "summarize counts line operations" {
  let stats = @MoonDiffKit.summarize([
    @MoonDiffKit.DiffOp::equal(0, 0, "a"),
    @MoonDiffKit.DiffOp::remove(1, "b"),
    @MoonDiffKit.DiffOp::add(1, "c"),
  ])
  assert_eq(stats.equal, 1)
  assert_eq(stats.added, 1)
  assert_eq(stats.removed, 1)
  assert_eq(stats.changed, 2)
  assert_true(stats.has_changes())
  assert_true(stats.to_json().contains("\"changed\":2"))
  assert_true(stats.to_summary().contains("added=1"))
}

///|
test "lcs length detects shared subsequence" {
  assert_eq(
    @MoonDiffKit.lcs_length(["keep", "old", "tail"], ["keep", "new", "tail"]),
    2,
  )
  assert_eq(@MoonDiffKit.lcs_length(["a", "b"], ["x", "y"]), 0)
}

///|
test "diff lines emits stable ordered operations" {
  let ops = @MoonDiffKit.diff_lines(["a", "b", "c"], ["a", "x", "c"])
  assert_eq(ops.length(), 4)
  assert_eq(ops[0].kind, "equal")
  assert_eq(ops[1].kind, "remove")
  assert_eq(ops[2].kind, "add")
  assert_eq(ops[3].text, "c")
  assert_eq(@MoonDiffKit.summarize(ops).changed, 2)
}

///|
test "diff text splits input and compares lines" {
  let ops = @MoonDiffKit.diff_text("a\nb\nc", "a\nx\nc")
  assert_eq(ops.length(), 4)
  assert_eq(ops[1].kind, "remove")
  assert_eq(ops[2].kind, "add")
  assert_eq(@MoonDiffKit.apply_ops(["a", "b", "c"], ops)[1], "x")
}

///|
test "unified patch uses familiar line prefixes" {
  let patch = @MoonDiffKit.to_unified_patch(
    @MoonDiffKit.diff_lines(["one", "two"], ["one", "three"]),
    old_label="before.txt",
    new_label="after.txt",
  )
  assert_true(patch.contains("--- before.txt"))
  assert_true(patch.contains("+++ after.txt"))
  assert_true(patch.contains("-two"))
  assert_true(patch.contains("+three"))
}

///|
test "context patch emits hunk headers and limited context" {
  let ops = @MoonDiffKit.diff_lines(["top", "keep", "old", "tail", "end"], [
    "top", "keep", "new", "tail", "end",
  ])
  let hunks = @MoonDiffKit.build_hunks(ops, context=1)
  assert_eq(hunks.length(), 1)
  assert_eq(hunks[0].old_count, 3)
  assert_eq(hunks[0].new_count, 3)
  assert_true(hunks[0].to_header().contains("@@ -2,3 +2,3 @@"))
  let patch = @MoonDiffKit.to_context_patch(
    ops,
    old_label="left.txt",
    new_label="right.txt",
    context=1,
  )
  assert_true(patch.contains("--- left.txt"))
  assert_true(patch.contains("@@ -2,3 +2,3 @@"))
  assert_true(patch.contains("-old"))
  assert_true(patch.contains("+new"))
}

///|
test "apply operations rebuilds the new side" {
  let old_lines = ["title", "old", "tail"]
  let new_lines = ["title", "new", "tail", "extra"]
  let ops = @MoonDiffKit.diff_lines(old_lines, new_lines)
  let rebuilt = @MoonDiffKit.apply_ops(old_lines, ops)
  assert_eq(rebuilt.length(), new_lines.length())
  assert_eq(rebuilt[1], "new")
  assert_eq(rebuilt[3], "extra")
}

///|
test "similarity uses lcs based per mille scale" {
  assert_eq(@MoonDiffKit.similarity_per_mille(["a", "b"], ["a", "b"]), 1000)
  assert_eq(@MoonDiffKit.similarity_per_mille(["a", "b"], ["x", "y"]), 0)
  assert_true(@MoonDiffKit.is_identical(["same"], ["same"]))
  assert_false(@MoonDiffKit.is_identical(["same"], ["changed"]))
}

///|
test "diff report summarizes hunks similarity and reversibility" {
  let report = @MoonDiffKit.diff_report(
    ["title", "old", "tail"],
    ["title", "new", "tail", "extra"],
    context=1,
  )
  assert_eq(report.hunks, 1)
  assert_eq(report.added, 2)
  assert_eq(report.removed, 1)
  assert_eq(report.changed, 3)
  assert_true(report.reversible)
  assert_true(report.to_json().contains("\"hunks\":1"))
}
