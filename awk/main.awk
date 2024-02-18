BEGIN {
  file=bookmarks_file
  bookmarks_count=0
  split("", list)
  split("", hash)
  load_bookmarks(file)
  RS="\x0c"
  PROCINFO["sorted_in"] = "@ind_num_asc"
  last = 0
}

{
  for (k = last + 1; k <= bookmarks_count; k++) {
    # if (list[k] == "Unscrambling C Declarations by Diagram")
      # printf "%s %s %s\n", NR, list[k], k

    # printf "=== page: %s, search bookmark %d: %s\n", NR, k, list[k]
    if (match($0, "(^|\n|Chapter | |\xe2\x80\xa6)"escape(list[k])"(\n|\xe2\x80\xa6| )") > 0) {
      hash[list[k]] = NR
      last = k
      # printf "= found page: %s <== bookmark %d: %s\n", NR, k, list[k]
    } else {
      next
    }
  }
}

END {
  for (k in list) {
    printf "%-3s|%s|\n", hash[list[k]], list[k]
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

