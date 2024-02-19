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
    if (match($0, regex_to_search_bookmark_title_in_pdf(list[k])) > 0 ) {
      modify_bookmark_title(list[k])
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
  if (test=="test")
    printf "%-3s|%s|\n", hash[list[k]], list[k]
  else
    printf "%s|%s\n", list[k], hash[list[k]]
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

