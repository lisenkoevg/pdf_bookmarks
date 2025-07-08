BEGIN {
  PDF_PAGE_SHIFT=20
  level = 0
}

{
  page_number = $NF + PDF_PAGE_SHIFT
  line = $0
  gsub(/ *-?[[:digit:]]+$/, "", line)
  if (line ~ /^ЧАСТЬ/)
    level = 0
  if (line ~ /^Глава/)
    level = 1
  else if (level == 1)
    level = 2
  printf "%d \"%s\" %d \"[%d/XYZ 0 0 null]\"\n", level, line, page_number, page_number
}
