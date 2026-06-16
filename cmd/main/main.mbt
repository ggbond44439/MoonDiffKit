///|
fn main {
  let old_lines = ["title", "old line", "tail"]
  let new_lines = ["title", "new line", "tail", "extra"]
  let ops = @diff.diff_lines(old_lines, new_lines)
  let stats = @diff.summarize(ops)
  let report = @diff.diff_report(old_lines, new_lines, context=1)
  println(stats.to_summary())
  println(report.to_json())
  println("similarity=\{@diff.similarity_per_mille(old_lines, new_lines)}")
  println(
    @diff.to_context_patch(
      ops,
      old_label="old.txt",
      new_label="new.txt",
      context=1,
    ),
  )
}
