BEGIN {
  file="bookmarks.txt"
  bookmarks_count=0
  split("", list)
  split("", hash)
  load_bookmarks(file)
  RS="\x0c"
  PROCINFO["sorted_in"] = "@ind_num_asc"
  last = 0
}

{
  if (NR > 10) nextfile
  for (k = last + 1; k <= bookmarks_count; k++) {
    if (hash[list[k]] == "") {
      printf "=== page: %s, search bookmark %d: %s\n", NR, k, list[k]
      if (index($0, "\n" list[k] "\n") > 0) {
        if (hash[list[k]] == "") {
          hash[list[k]] = NR
          last = k
          printf "= found page: %s <== bookmark %d: %s\n", NR, k, list[k]
        }
      }
    }
  }
}

END {
  for (k in list) {
    printf "%5s '%s'\n", hash[list[k]], list[k]
  }
}

function load_bookmarks(file,    k, i) {
  while ((getline k < file) > 0) {
    if (!match(k, "^\\s*$")) {
      list[++i] = k 
      hash[k] = ""
    }
  }
  bookmarks_count = i
  close(file)
}

