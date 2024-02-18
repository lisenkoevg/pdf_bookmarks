#!/bin/bash

sed -n -e '/^\s*$/d; /^#/d' \
  -e 's/“\|”/"/g' \
  -e "s/’/'/g" \
  -E -e 's/Diagram (A|B|C)/Figure \1\./' \
  -E -e "s/(It May Be Crufty)(, but It's the Only Game in Town)/\1 \[4\]\2/" \
  -e 's/Appendix: //' \
  -e '/Further Reading/d' \
  -e 'p' < bookmarks.txt > tmp/bookmarks.tmp
  # -e 's/\.\.\./\xe2\x80\xa6/' \

# pdftotext -enc UTF-8 "$1" - |
[ ! -e "$1" ] && { echo File no specified; exit; }
awk -v bookmarks_file=tmp/bookmarks.tmp -f awk/lib.awk -f awk/main.awk < "$1"

