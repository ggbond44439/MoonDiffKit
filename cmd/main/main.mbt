///|
fn main {
  let old_lines = ["title", "old line", "tail"]
  let new_lines = ["title", "new line", "tail", "extra"]
  let ops = @diff.diff_lines(old_lines, new_lines)
  let stats = @diff.summarize(ops)
  println(stats.to_summary())
  println("similarity=\{@diff.similarity_per_mille(old_lines, new_lines)}")
  println(@diff.to_unified_patch(ops, old_label="old.txt", new_label="new.txt"))
}
