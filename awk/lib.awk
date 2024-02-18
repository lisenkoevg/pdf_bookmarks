function escape(str) {
  gsub(/\$/, "\\$", str)
  gsub(/\?/, "\\?", str)
  gsub(/\[/, "\\[", str)
  gsub(/\]/, "\\]", str)
  gsub(/\+/, "\\+", str)
  return str
  # return gensub(/(\$|\?|\[|\])/, "\\\1", "g", str)
}
