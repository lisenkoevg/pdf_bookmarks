# defaults:
#   level = 1
#   not_preface = 0
function set_bookmark_level(line) {
  if (line ~ "^[A-Z][a-z]\\|")
    level = 1
  else
    level = 2
  return level
}

function guess_bookmark(page_content, output,   arr, re, m) {
  split("", output)
  if (NR < 11 || NR > 1177) return

  re = "\\n([A-Z][a-z])( S)?\\n"
  m = match(page_content, re, arr)
  if (m) {
    output[0] = arr[1]
  }

  if (match(page_content, /^[0-9]+\n\n([a-zA-Z, ]+)\n|^([a-zA-Z, ]+)\n/, arr)) {
    output[1] = arr[1] arr[2]
  }

#   Xx and Yy is on the same page, so repeat 1 step
  page_content = substr(page_content, m + 2)
  m = match(page_content, re, arr)
  if (m) {
    output[2] = arr[1]
  }
}

