BEGIN {
  file=bookmarks_file
  bookmarks_count=0
  split("", list)
  split("", hash)
  skip_bookmark_extraction = 0
  if ("" != file)
    load_bookmarks(file)
  else
    skip_bookmark_extraction = 1
  RS="\x0c"
  PROCINFO["sorted_in"] = "@ind_num_asc"
  last = 0
}

{
  if (0 == skip_bookmark_extraction) {
    for (k = last + 1; k <= bookmarks_count; k++) {
      if (match($0, regex_to_search_bookmark_title_in_pdf(list[k])) > 0 ) {
        list[k] = modify_bookmark_title(list[k])
        hash[list[k]] = NR
        last = k
        # printf "= found page: %s <== bookmark %d: %s\n", NR, k, list[k]
      } else {
        next
      }
    }
  }

# Try to guess bookmarks
  if (1 == skip_bookmark_extraction) {
    split("", guessed)
    guess_bookmark($0, guessed)
    for (k in guessed) {
      if (!guessed[k])
        continue
      if (guessed[k] && bookmarks_count in list && guessed[k] == list[bookmarks_count]) {
        continue
      }

      list[++bookmarks_count] = guessed[k]
      hash[guessed[k]] = NR
    }
  }
}

END {
  for (k in list) {
    if (test=="test")
      printf "%-4s|%s|\n", hash[list[k]], list[k]
    else
      printf "%s|%s\n", list[k], hash[list[k]]
  }
}

function load_bookmarks(file,    k, i) {
  i = 0
  while ((getline k < file) > 0) {
    if (!match(k, "^\\s*$")) {
      list[++i] = k
      hash[k] = ""
    }
  }
  bookmarks_count = i
  close(file)
}

