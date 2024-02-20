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
  tmpDir="tmp/${pdf_base%.pdf}"

  [ ! -d "$conf_dir" ] && {
    printf "conf dir '%s' not exists\n", "$conf_dir"
    exit 1
  }
  mkdir -p "$tmpDir"
  bookmarks_pre=""
  if [ -e "${conf_dir}/bookmarks.txt" ]
  then
    bookmarks_pre="$tmpDir/bookmarks.tmp"
    prepare_bookmarks
  fi
  eval_bookmark='awk -v test="$1" -v bookmarks_file="$bookmarks_pre" -f awk/lib.awk -f "$conf_dir/lib.awk" -f awk/extract_page_numbers_from_pdf.awk'

  # when testing, treat input file as text already extracted with pdftotext
  [ "$1" == "test" ] && {
    eval "$eval_bookmark" < "$3"
    exit
  }

  # main
  trap 'RC=1' ERR

  echo Rebuilding pdf...
  pdftotext -enc UTF-8 -eol unix "$input" - |
    eval "$eval_bookmark" |
    awk -f "$conf_dir/lib.awk" -f awk/generate_bookmarks_data.awk > "$tmpDir/bookmarks_pdf.tmp"

  pdftk "$input" dump_data output - | dos2unix > "$tmpDir/dump_data.tmp"
  sed '/^Bookmark/d' -i "$tmpDir/dump_data.tmp"
  sed "/^NumberOfPages/r $tmpDir/bookmarks_pdf.tmp" "$tmpDir/dump_data.tmp" > "$tmpDir/dump_data_new.tmp"
  diff "$tmpDir/dump_data.tmp" "$tmpDir/dump_data_new.tmp" > /dev/null && {
    echo Bookmarks not added... abort
    exit
  }
  name=$(basename "$input")
  pdftk "$input" update_info "$tmpDir/dump_data_new.tmp" output "$tmpDir/$name"

  [ -z "$RC" ] && printf "%s\n" "$(md5sum "$tmpDir/$name")"
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
    < "${conf_dir}/bookmarks.txt" > "$tmpDir/bookmarks.tmp"
}

main "$@"
