function escape(str) {
  gsub(/\$/, "\\$", str)
  return str
}
