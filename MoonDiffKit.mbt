///|
pub(all) struct DiffOp {
  kind : String
  old_index : Int
  new_index : Int
  text : String
} derive(Debug, Eq)

///|
pub(all) struct DiffStats {
  equal : Int
  added : Int
  removed : Int
  changed : Int
} derive(Debug, Eq)

///|
pub(all) struct DiffHunk {
  old_start : Int
  old_count : Int
  new_start : Int
  new_count : Int
  ops : Array[DiffOp]
} derive(Debug, Eq)

///|
pub(all) struct DiffReport {
  hunks : Int
  equal : Int
  added : Int
  removed : Int
  changed : Int
  similarity : Int
  reversible : Bool
} derive(Debug, Eq)

///|
pub fn DiffOp::equal(old_index : Int, new_index : Int, text : String) -> DiffOp {
  { kind: "equal", old_index, new_index, text }
}

///|
pub fn DiffOp::add(new_index : Int, text : String) -> DiffOp {
  { kind: "add", old_index: -1, new_index, text }
}

///|
pub fn DiffOp::remove(old_index : Int, text : String) -> DiffOp {
  { kind: "remove", old_index, new_index: -1, text }
}

///|
pub fn DiffOp::is_change(self : DiffOp) -> Bool {
  self.kind != "equal"
}

///|
pub fn DiffStats::empty() -> DiffStats {
  { equal: 0, added: 0, removed: 0, changed: 0 }
}

///|
pub fn summarize(ops : Array[DiffOp]) -> DiffStats {
  let mut equal = 0
  let mut added = 0
  let mut removed = 0
  for op in ops {
    if op.kind == "equal" {
      equal = equal + 1
    } else if op.kind == "add" {
      added = added + 1
    } else if op.kind == "remove" {
      removed = removed + 1
    }
  }
  { equal, added, removed, changed: added + removed }
}

///|
pub fn DiffStats::has_changes(self : DiffStats) -> Bool {
  self.changed > 0
}

///|
pub fn DiffStats::to_json(self : DiffStats) -> String {
  "{\"equal\":\{self.equal},\"added\":\{self.added},\"removed\":\{self.removed},\"changed\":\{self.changed}}"
}

///|
pub fn DiffStats::to_summary(self : DiffStats) -> String {
  "equal=\{self.equal}, added=\{self.added}, removed=\{self.removed}, changed=\{self.changed}"
}

///|
pub fn DiffHunk::to_header(self : DiffHunk) -> String {
  "@@ -\{self.old_start + 1},\{self.old_count} +\{self.new_start + 1},\{self.new_count} @@"
}

///|
pub fn DiffReport::to_json(self : DiffReport) -> String {
  "{\"hunks\":\{self.hunks},\"equal\":\{self.equal},\"added\":\{self.added},\"removed\":\{self.removed},\"changed\":\{self.changed},\"similarity\":\{self.similarity},\"reversible\":\{self.reversible}}"
}

///|
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn table_index(width : Int, row : Int, col : Int) -> Int {
  row * width + col
}

///|
fn build_lcs_table(
  old_lines : Array[String],
  new_lines : Array[String],
) -> Array[Int] {
  let width = new_lines.length() + 1
  let table = Array::make((old_lines.length() + 1) * width, 0)
  for i = 1; i <= old_lines.length(); i = i + 1 {
    for j = 1; j <= new_lines.length(); j = j + 1 {
      let idx = table_index(width, i, j)
      if old_lines[i - 1] == new_lines[j - 1] {
        table[idx] = table[table_index(width, i - 1, j - 1)] + 1
      } else {
        table[idx] = max_int(
          table[table_index(width, i - 1, j)],
          table[table_index(width, i, j - 1)],
        )
      }
    }
  }
  table
}

///|
pub fn lcs_length(old_lines : Array[String], new_lines : Array[String]) -> Int {
  let width = new_lines.length() + 1
  let table = build_lcs_table(old_lines, new_lines)
  table[table_index(width, old_lines.length(), new_lines.length())]
}

///|
fn reverse_ops(ops : Array[DiffOp]) -> Array[DiffOp] {
  let result : Array[DiffOp] = []
  let mut index = ops.length() - 1
  while index >= 0 {
    result.push(ops[index])
    index = index - 1
  }
  result
}

///|
pub fn split_lines(text : String) -> Array[String] {
  let lines : Array[String] = []
  let mut start = 0
  for i = 0; i < text.length(); i = i + 1 {
    match text.get_char(i) {
      Some('\n') => {
        lines.push(text.unsafe_substring(start~, end=i))
        start = i + 1
      }
      _ => ()
    }
  }
  lines.push(text.unsafe_substring(start~, end=text.length()))
  lines
}

///|
pub fn diff_text(old_text : String, new_text : String) -> Array[DiffOp] {
  diff_lines(split_lines(old_text), split_lines(new_text))
}

///|
pub fn diff_lines(
  old_lines : Array[String],
  new_lines : Array[String],
) -> Array[DiffOp] {
  let width = new_lines.length() + 1
  let table = build_lcs_table(old_lines, new_lines)
  let reversed : Array[DiffOp] = []
  let mut i = old_lines.length()
  let mut j = new_lines.length()
  while i > 0 || j > 0 {
    if i > 0 && j > 0 && old_lines[i - 1] == new_lines[j - 1] {
      reversed.push(DiffOp::equal(i - 1, j - 1, old_lines[i - 1]))
      i = i - 1
      j = j - 1
    } else if j > 0 &&
      (
        i == 0 ||
        table[table_index(width, i, j - 1)] >=
        table[table_index(width, i - 1, j)]
      ) {
      reversed.push(DiffOp::add(j - 1, new_lines[j - 1]))
      j = j - 1
    } else {
      reversed.push(DiffOp::remove(i - 1, old_lines[i - 1]))
      i = i - 1
    }
  }
  reverse_ops(reversed)
}

///|
fn find_first_change(ops : Array[DiffOp]) -> Int {
  for i = 0; i < ops.length(); i = i + 1 {
    if ops[i].is_change() {
      return i
    }
  }
  -1
}

///|
fn find_last_change(ops : Array[DiffOp]) -> Int {
  let mut i = ops.length() - 1
  while i >= 0 {
    if ops[i].is_change() {
      return i
    }
    i = i - 1
  }
  -1
}

///|
fn count_old_ops(ops : Array[DiffOp]) -> Int {
  let mut count = 0
  for op in ops {
    if op.kind == "equal" || op.kind == "remove" {
      count = count + 1
    }
  }
  count
}

///|
fn count_new_ops(ops : Array[DiffOp]) -> Int {
  let mut count = 0
  for op in ops {
    if op.kind == "equal" || op.kind == "add" {
      count = count + 1
    }
  }
  count
}

///|
fn first_old_index(ops : Array[DiffOp]) -> Int {
  for op in ops {
    if op.kind == "equal" || op.kind == "remove" {
      return op.old_index
    }
  }
  0
}

///|
fn first_new_index(ops : Array[DiffOp]) -> Int {
  for op in ops {
    if op.kind == "equal" || op.kind == "add" {
      return op.new_index
    }
  }
  0
}

///|
pub fn build_hunks(ops : Array[DiffOp], context? : Int = 3) -> Array[DiffHunk] {
  let hunks : Array[DiffHunk] = []
  let first_change = find_first_change(ops)
  if first_change < 0 {
    return hunks
  }
  let last_change = find_last_change(ops)
  let safe_context = if context < 0 { 0 } else { context }
  let start = if first_change > safe_context {
    first_change - safe_context
  } else {
    0
  }
  let end = min_int(last_change + safe_context + 1, ops.length())
  let hunk_ops : Array[DiffOp] = []
  for i = start; i < end; i = i + 1 {
    hunk_ops.push(ops[i])
  }
  hunks.push({
    old_start: first_old_index(hunk_ops),
    old_count: count_old_ops(hunk_ops),
    new_start: first_new_index(hunk_ops),
    new_count: count_new_ops(hunk_ops),
    ops: hunk_ops,
  })
  hunks
}

///|
pub fn to_unified_patch(
  ops : Array[DiffOp],
  old_label? : String = "old",
  new_label? : String = "new",
) -> String {
  let buf = StringBuilder()
  buf.write_string("--- " + old_label + "\n")
  buf.write_string("+++ " + new_label + "\n")
  buf.write_string("@@\n")
  for op in ops {
    if op.kind == "equal" {
      buf.write_string(" " + op.text + "\n")
    } else if op.kind == "add" {
      buf.write_string("+" + op.text + "\n")
    } else if op.kind == "remove" {
      buf.write_string("-" + op.text + "\n")
    }
  }
  buf.to_string()
}

///|
pub fn to_context_patch(
  ops : Array[DiffOp],
  old_label? : String = "old",
  new_label? : String = "new",
  context? : Int = 3,
) -> String {
  let buf = StringBuilder()
  buf.write_string("--- " + old_label + "\n")
  buf.write_string("+++ " + new_label + "\n")
  let hunks = build_hunks(ops, context~)
  for hunk in hunks {
    buf.write_string(hunk.to_header() + "\n")
    for op in hunk.ops {
      if op.kind == "equal" {
        buf.write_string(" " + op.text + "\n")
      } else if op.kind == "add" {
        buf.write_string("+" + op.text + "\n")
      } else if op.kind == "remove" {
        buf.write_string("-" + op.text + "\n")
      }
    }
  }
  buf.to_string()
}

///|
pub fn apply_ops(
  _old_lines : Array[String],
  ops : Array[DiffOp],
) -> Array[String] {
  let result : Array[String] = []
  for op in ops {
    if op.kind == "equal" || op.kind == "add" {
      result.push(op.text)
    }
  }
  result
}

///|
pub fn similarity_per_mille(
  old_lines : Array[String],
  new_lines : Array[String],
) -> Int {
  let total = old_lines.length() + new_lines.length()
  if total == 0 {
    1000
  } else {
    lcs_length(old_lines, new_lines) * 2000 / total
  }
}

///|
pub fn is_identical(
  old_lines : Array[String],
  new_lines : Array[String],
) -> Bool {
  old_lines.length() == new_lines.length() &&
  similarity_per_mille(old_lines, new_lines) == 1000
}

///|
pub fn diff_report(
  old_lines : Array[String],
  new_lines : Array[String],
  context? : Int = 3,
) -> DiffReport {
  let ops = diff_lines(old_lines, new_lines)
  let stats = summarize(ops)
  let rebuilt = apply_ops(old_lines, ops)
  {
    hunks: build_hunks(ops, context~).length(),
    equal: stats.equal,
    added: stats.added,
    removed: stats.removed,
    changed: stats.changed,
    similarity: similarity_per_mille(old_lines, new_lines),
    reversible: is_identical(rebuilt, new_lines),
  }
}
