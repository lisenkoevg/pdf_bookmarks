#!/bin/bash

pdf='Martin - Mastering Cmake (OCR).pdf'

script='BEGIN {
  FS = "|"
  level = 0
  title = ""
}
{
  if ($0 ~ /^(Chapter|Appendix|Index)/)
    level = 1
  else
    level = 2

  title = $1
  page = $2

  printf "BookmarkBegin\n"
  printf "BookmarkTitle: %s\n", title
  printf "BookmarkLevel: %d\n", level
  printf "BookmarkPageNumber: %d\n", page
}'
# printf '%s\n' "$script"

sed -E -e '/^$/d' \
  -e 's/^(Chapter [0-9]* .)(.*)$/\1\L\2/' \
  -e 's/^(Chapter.*)(c)(make)/\1\u\2\3/; s/^(Appendix.* . - .)(.*)$/\1\L\2/' \
  -e '/^(Chapter|Appendix|Index|[0-9])/b; s/^(.*)$/    &/' outline.txt > outline.tmp
pr -m -t -J -S'|' outline.tmp pages.txt > combined.tmp
awk -e "$script" < combined.tmp > bookmarks.tmp
pdftk "$pdf" dump_data output dump_data.tmp
sed '/^NumberOfPages/r bookmarks.tmp' dump_data.tmp > dump_data_new.tmp
pdftk "$pdf" update_info dump_data_new.tmp output "${pdf/.pdf/_new.pdf}"
# rm -f ./*.tmp
