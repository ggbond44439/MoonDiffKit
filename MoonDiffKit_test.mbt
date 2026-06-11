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
