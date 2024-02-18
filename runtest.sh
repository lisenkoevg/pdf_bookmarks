#!/bin/bash -i


[ -z $1 ] && for f in $(ls -1 test/*.in | sort -V)
do
  out="${f/.in/\.out}"
  actual="${out/.out/_actual.out}"
  ./main.sh "$f" > "$actual"
  diff -N "$actual" "$out" > /dev/null && {
    echo_green "$f" ok;
    rm "$actual"
  } || {
    echo_red "$f" failed;
  }
done

function gen_test_data() {
  input="../Linden - Expert C Programming,1994.pdf"
  mkdir -p test/1/
  for i in $(seq 290 290) 
  do
    pdftotext -f 1 -l $i -enc UTF-8 "$input" - | dos2unix > test/1/$i.in
  done
}

[ "$1" == "gen" ] && gen_test_data

function rename_test_result_files() {
  str=""
  for f in $(ls -1 test/*actual.out | sort -V)
  do
    expected=${f/_actual/}
    [ -e "$expected" ] && {
      str="$str;mv -f -v $f $expected"
    }
  done
  str=${str#;}
  printf "%s\n" "$str" | tr ";" "\n"
  read -p "Press key to continue..."
  eval "$str"
  unset str expected f
}
[ "$1" == "rename" ] && rename_test_result_files
