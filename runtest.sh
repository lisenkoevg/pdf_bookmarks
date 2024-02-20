#!/bin/bash -i


# script [ gen | rename ]
# if no param - run test
# PDF_FILE envvar must be set
# PDF_FILE as pdf used in gen_test_data
# in other cases PDF_FILE is used for its basename to find test directory


function main() {
  [ ! -e "$PDF_FILE" ] && {
    printf "Env variable PDF_FILE not set or file '$PDF_FILE' not exists\n\n" "$PDF_FILE"
    usage
    exit 1
  }
  base=`basename "$PDF_FILE"`
  test_dir="test/${base%.pdf}"
  [ -d "$test_dir" ] || {
    printf "test dir '$test_dir' not exists\n"
    return 1
  }
  [ "$1" == "gen" ] && {
    shift
    gen_test_data "$@"
    return
  }
  [ "$1" == "rename" ] && {
    rename_test_result_files
    return
  }
  OLD_IFS=$IFS
  IFS=$'\n'
  [ -f "$test_dir/test.tar.xz" ] && {
    echo Unpacking tests...
    tar xf "$test_dir/test.tar.xz" -C "$test_dir"
    # tar --extract --file="$test_dir/test.tar.xz"  --directory="$test_dir" --verbose
  } || {
    \ls -1 "$test_dir" | sort -V | grep -E "\.(in|out)" |
      tar Jcvf "$test_dir/test.tar.xz" -C "$test_dir" --exclude=*.xz -T -
    # \ls -1 "$test_dir" | tar --create --directory="$test_dir" --file="$test_dir/test.tar.xz"  --verbose --xz --exclude=*.xz --files-from=-
    :
  }
  printf "Using test dir '%s'\n" "$test_dir"
  for f in $(\ls -1 "$test_dir/"*.in | sort -V)
  do
    out="${f/.in/\.out}"
    actual="${out/.out/_actual.out}"
    ./main.sh test "$PDF_FILE" "$f" > "$actual"
    diff -N "$actual" "$out" > /dev/null && {
      echo_green "$f ok";
      rm "$actual"
    } || {
      echo_red "$f failed";
    }
  done
  IFS=$OLD_IFS
  unset test_dir OLD_IFS base
}

# gen_test_data 1 2 10 - извлечь текст из pdf в файлы 1.in 3.in 5.in 7.in 9.in
# с соответственно первой страницей, первыми тремя страница, первыми пятью и т.д.
function gen_test_data() {
  mkdir -p "$test_dir/gen/"
  for i in $(seq "$@")
  do
    echo Export pages from 1 to $i...
    pdftotext -f 1 -l $i -enc UTF-8 -eol unix "$(cygpath -m "$PDF_FILE")" "$test_dir/gen/$i.in"
  done
}


function rename_test_result_files() {
  str=""
  OLD_IFS=$IFS
  IFS=$'\n'
  for f in $(\ls -N1 "$test_dir/"*actual.out 2>/dev/null | sort -V)
  do
    expected="${f/_actual/}"
    [ -e "$expected" ] && {
      str="$str;mv -f -v '$f' '$expected'"
    }
  done
  IFS=$OLD_IFS
  [ -z "$str" ] && { echo Nothing to rename; exit; }
  str=${str#;}
  printf "%s\n" "$str" | tr ";" "\n"
  read -p "Press key to continue..."
  eval "$str"
  unset str expected f OLD_IFS
}

function usage() {
  printf "Example:\n"
  printf "PDF_FILE='D:/YandexDisk/Книги/Программирование/C/Linden - Expert C Programming/orig/Linden - Expert C Programming, 1994.pdf' "
  printf "./runtest.sh\n\n"
}

main "$@"

