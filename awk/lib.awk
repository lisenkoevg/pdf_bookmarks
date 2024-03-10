function escape(str) {
  gsub(/\$/, "\\$", str)
  gsub(/\?/, "\\?", str)
  gsub(/\[/, "\\[", str)
  gsub(/\]/, "\\]", str)
  gsub(/\+/, "\\+", str)
  return str
  # return gensub(/(\$|\?|\[|\])/, "\\\1", "g", str)
}

function alen(a,    i, k) {
  k = 0
  for(i in a) k++
  return k
}
