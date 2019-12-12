#!/bin/bash


	cloc . --csv --out cloc-report.csv
	tail -n +2 cloc-report.csv | sed 's/^/{\"files": /' | sed 's/,/, "lang": "/' | sed 's/,/", "blank": /2'  | sed 's/,/, "comment": /3' | sed 's/,/, "code": /4' | sed 's/$/}/' | paste -sd "," - > cloc-report.json
	TOTO=$(cat cloc-report.json)
	echo "[$TOTO]"
	CLOC=$(echo "[$TOTO]" | jq .)
