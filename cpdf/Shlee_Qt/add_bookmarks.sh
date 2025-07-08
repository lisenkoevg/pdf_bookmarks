#!/bin/bash

# Шлее М. - Qt 5.10. Профессиональное программирование на C++ - 2018.pdf

PDF_IN=qt.pdf
PDF_OUT=${PDF_IN/.pdf/_out.pdf}

BOOKMARKS_RAW=bookmarks.txt
BOOKMARKS_CLEANED=${BOOKMARKS_RAW/.txt/_clean.txt}
BOOKMARKS_HIER=${BOOKMARKS_RAW/.txt/_hier.txt}

main() {
  prepare_bookmarks
  add_bookmarks_to_pdf
  remove_intermediate
}

prepare_bookmarks() {
  clean_bookmarks
  hierarchize_bookmarks
}

clean_bookmarks() {
  q=10000
  cat $BOOKMARKS_RAW | grep . | sed -E \
    -e '2,$s/ *[XIV]* *Оглавление *[XIV]* *//' \
    -e 's/ *\.\.+ */ /g;s/\x02//g; s/ +$//;' \
    -e ${q}q > $BOOKMARKS_CLEANED
}

hierarchize_bookmarks() {
  gawk -f hierarchize.awk $BOOKMARKS_CLEANED > $BOOKMARKS_HIER
}

add_bookmarks_to_pdf() {
#   cat -n $BOOKMARKS_HIER
  cpdf -add-bookmarks $BOOKMARKS_HIER $PDF_IN -o $PDF_OUT
}

remove_intermediate() {
  rm -f $BOOKMARKS_CLEANED
}

main $*
