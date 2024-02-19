BEGIN {
  FS = "|"
  level = 1
  not_preface = 0 
}
{
  set_bookmark_level($0)

  printf "BookmarkBegin\n"
  printf "BookmarkTitle: %s\n", $1
  printf "BookmarkLevel: %d\n", level
  printf "BookmarkPageNumber: %d\n", $2
}

