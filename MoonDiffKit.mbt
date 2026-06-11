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
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
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
