# defaults:
#   level = 1
#   not_preface = 0
function set_bookmark_level(line) {
  if (line ~ /^[0-9]+\./) {
    level = 1
    not_preface = 1
  } else if (not_preface == 1) {
    level = 2
  }
}

function modify_bookmark_title(title) {
# Such symbol display ierogliphs in pdf viewer bookmarks.
# It's not possible to modify source bookmarks.txt
# because pdf content has such symbols
  sub(/\xe2\x80\x94/, "-", title) # long dash
  return title
}

function regex_to_search_bookmark_title_in_pdf(val) {
  # mnogotochie
  return "(^|\n|Chapter | |\xe2\x80\xa6)" escape(val) "(\n|\xe2\x80\xa6| )"
}
