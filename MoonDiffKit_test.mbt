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
