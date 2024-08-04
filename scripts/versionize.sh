#!/bin/bash

for file in $(find . -maxdepth 1 -type f \( -iname "*.typ" -o -iname "*.tex" \) -and \( -not -name "conf.typ" -not -iname "_*.typ" \)); do
  if [ -f "$file" ]; then
    OUTPUT_FILE=$(echo $file | sed -E -e "s/\.(typ|tex)$/.pdf/" | cut -c3-)
    echo "DATE PARSING for $OUTPUT_FILE"
    # get date from git
    DATE=$(git log --pretty=format:%ad --date=format:'%Y-%m-%d' -n 1 -- $file)

    #add to json
    if hash jq 2> /dev/null; then
      jq --arg output "$OUTPUT_FILE" --arg date "$DATE" '
  if (.[$output] | type != "object") then
    .[$output] = {"date": $date}
  else
    .[$output].date = $date
  end
' "$1" > tmp && mv tmp "$1"
    else
      echo "JQ not installed"
    fi
  fi
done
