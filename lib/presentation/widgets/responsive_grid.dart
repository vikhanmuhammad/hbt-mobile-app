/// Breakpoint grid kategori sesuai DESIGN.md §3: 2 kolom (<600dp),
/// 3 kolom (600-900dp), 4 kolom (>=900dp).
int categoryGridColumns(double width) {
  if (width >= 900) return 4;
  if (width >= 600) return 3;
  return 2;
}
