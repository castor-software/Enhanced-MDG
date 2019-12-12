#!/bin/bash

#github.com/bpark/cdi-bean-utils.git

toJ()
{
	RAW=$1
	GROUP=$(echo $RAW | cut -d '/' -f2)
	ARTIFACT=$(echo $RAW | cut -d '/' -f3 | cut -d '.' -f1)
	GA="$GROUP:$ARTIFACT"

	URL="https://$RAW"

	amqp-publish -r artifacts  -C "application/json" --url amqp://gjkdghkdfgk:dshkdsghj@serveur-du-placard.ml:53672 --ssl -b "{\"ga\": \"$GA\",\"repo\": \"$URL\", \"dataset\":\"test\"}"
}


if (( ${#} == 0 )) ; then
    while read -r line ; do
        toJ "${line}"
    done
else
    toJ "${@}"
fi
