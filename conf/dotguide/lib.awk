# defaults:
#   level = 1
#   not_preface = 0
function set_bookmark_level(line) {
  if (line !~ /[1-9]\.[1-9]/) {
    level = 1
  } else {
    level = 2
  }
}

function guess_bookmark(page_content, output) {
  split(page_content, output, /\n+/)
  PROCINFO["sorted_in"] = "@ind_num_asc"
  for (i in output) {
    if (length(output[i]) < 60 && output[i] ~ /^[1-9A-Z](\.[1-9]+)?\s.{5,}$/)
      # printf "output[%s] = '%s' %s\n", i, output[i], NR
      ;
    else
      delete output[i]
  }
}
