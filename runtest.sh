#!/bin/bash -i


for f in `ls -1 test/*.in | sort -V`
do
  out="${f/.in/\.out}"
  ./main.sh "$f" "$out"
  diff -N "$f" "$out" && {
    echo_green "$f" ok;
  } || {
    echo_red "$f" failed;
  }
done

function get_test_data() {
  input="../Linden - Expert C Programming,1994.pdf"
  for i in $(seq 2 10) 
  do
    pdftotext -f 1 -l $i -enc UTF-8 "$input" test/$i.in
  done
}
