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
