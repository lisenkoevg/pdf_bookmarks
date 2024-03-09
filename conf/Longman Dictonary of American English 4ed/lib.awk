# defaults:
#   level = 1
#   not_preface = 0
function set_bookmark_level(line) {
  level = 1
}

function guess_bookmark(page_content, output) {
  split(page_content, output, /\n+/)
  PROCINFO["sorted_in"] = "@ind_num_asc"
  for (i in output) {
    if (output[i] ~ /^[A-Z][a-z]( S)?$/)
      output[i] = substr(output[i], 1, 1)
    else
      delete output[i]
  }
}
