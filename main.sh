#!/bin/bash

function main() {
  [ -e "$1" ] || { echo File "$1" not exists; exit; }

  prepare_bookmarks

  eval_bookmark='awk -v test="$2" -v bookmarks_file=tmp/bookmarks.tmp -f awk/lib.awk -f awk/extract_page_numbers_from_pdf.awk'

  # when testing, pass file with text already extracted with pdftotext
  [ "$2" == "test" ] && { eval "$eval_bookmark" < "$1"; exit; }

  # main
  trap 'RC=1' ERR

  pdftotext -enc UTF-8 "$1" - |
    dos2unix | eval "$eval_bookmark" |
    awk -f awk/generate_bookmarks_data.awk > tmp/bookmarks_pdf.tmp
  pdftk "$1" dump_data output tmp/dump_data.tmp
  sed '/^NumberOfPages/r tmp/bookmarks_pdf.tmp' tmp/dump_data.tmp > tmp/dump_data_new.tmp
  name=$(basename "$1")
  pdftk "$1" update_info tmp/dump_data_new.tmp output "tmp/$name"

  echo Return code: $RC
  unset eval_bookmark name RC
}

function prepare_bookmarks() {
  sed -n -e '/^\s*$/d; /^#/d' \
    -e 's/“\|”/"/g' \
    -e "s/’/'/g" \
    -E -e 's/Diagram (A|B|C)/Figure \1\./' \
    -E -e "s/(It May Be Crufty)(, but It's the Only Game in Town)/\1 \[4\]\2/" \
    -e 's/Appendix: //' \
    -e '/Further Reading/d' \
    -e 'p' < bookmarks.txt > tmp/bookmarks.tmp
}

main "$@"
