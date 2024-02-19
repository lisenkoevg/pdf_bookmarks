#!/bin/bash


function main() {
  [ "$1" != "build" -a "$1" != "test" ] && {
    usage
    exit 1
  }
  [ ! -e "$2" ] && {
    printf "bad file '%s'\n", "$2"
    exit 1
  }

  input="$(cygpath -m "$2")"
  pdf_base=`basename "$input"`
  conf_dir="./conf/${pdf_base%.pdf}"

  [ ! -d "$conf_dir" ] && {
    printf "conf dir '%s' not exists\n", "$conf_dir"
    exit 1
  }

  prepare_bookmarks $pdf_base
  eval_bookmark='awk -v test="$1" -v bookmarks_file=tmp/bookmarks.tmp -f awk/lib.awk -f "$conf_dir/lib.awk" -f awk/extract_page_numbers_from_pdf.awk'

  # when testing, treat input file as text already extracted with pdftotext
  [ "$1" == "test" ] && {
    eval "$eval_bookmark" < "$3"
    exit
  }

  # main
  trap 'RC=1' ERR

  echo Rebuilding pdf...

  pdftotext -enc UTF-8 "$input" - |
    dos2unix | eval "$eval_bookmark" |
    awk -f "$conf_dir/lib.awk" -f awk/generate_bookmarks_data.awk > tmp/bookmarks_pdf.tmp

  pdftk "$input" dump_data output tmp/dump_data.tmp
  sed '/^NumberOfPages/r tmp/bookmarks_pdf.tmp' tmp/dump_data.tmp > tmp/dump_data_new.tmp

  name=$(basename "$input")
  pdftk "$input" update_info tmp/dump_data_new.tmp output "tmp/$name"

  [ -z "$RC" ] && printf "%s\n" "$(md5sum "tmp/$name")"
  [ -n "$RC" ] && echo Return code: $RC

  unset eval_bookmark name RC pdf pdf_base
}

function usage() {
  printf 'Usage: script <build | test> <pdf_filename> <test_input_file>\n'
  printf '("test" is used by runtest.sh)\n\n'
  printf 'Example:\n'
  printf './main.sh build "D:/YandexDisk/Книги/Программирование/C/Linden - Expert C Programming/orig/Linden - Expert C Programming, 1994.pdf"\n\n'
}

function prepare_bookmarks() {
  sed -n -E \
    -f "${conf_dir}/bookmarks_prepare.sed" \
    -e 'p' \
    < "${conf_dir}/bookmarks.txt" > tmp/bookmarks.tmp
}

main "$@"
