BEGIN {
  FS = "|"
  level = 1
  intro = 1
  title = ""
}
{
  if ($0 ~ /^[0-9]+\./) {
    level = 1
    intro = 0
  } else if (intro == 0) {
    level = 2
  }

  title = $1
  page = $2

  printf "BookmarkBegin\n"
  printf "BookmarkTitle: %s\n", title
  printf "BookmarkLevel: %d\n", level
  printf "BookmarkPageNumber: %d\n", page
}
