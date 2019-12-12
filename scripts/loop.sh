#!/bin/bash

function process {
	OOO=$(echo $1 | jq '.')
	echo $OOO
	echo $OOO 1>2
}

CONFIG_FILE="./config.json"

#{
#	"node-name":"node1",
#	"broker-url":"amqp://gjkdghkdfgk:dshkdsghj@serveur-du-placard.ml:53672",
#	"in-queue":"",
#	"out-queue":"",
#	"err-queue":""
#}


BROKER_URL=$(cat $CONFIG_FILE | jq -r '.broker')
NODE_NAME=$(cat $CONFIG_FILE | jq -r '.node')
IN_Q=$(cat $CONFIG_FILE | jq -r '.inq')
OUT_Q=$(cat $CONFIG_FILE | jq -r '.outq')
ERR_Q=$(cat $CONFIG_FILE | jq -r '.errq')

TMP_IN="tmp_in"
TMP_OUT="tmp_out"
TMP_ERR="tmp_err"

rm $TMP_OUT
rm $TMP_IN
rm $TMP_ERR


echo "BROKER_URL: $BROKER_URL"
echo "NODE_NAME: $NODE_NAME"
echo "IN_Q: $IN_Q"
echo "OUT_Q: $OUT_Q"
echo "ERR_Q: $ERR_Q"


while DATA=$(amqp-get --url $BROKER_URL --ssl -q $IN_Q)
do
	echo "DATA: $DATA"
	echo $DATA > $TMP_IN
	#process $DATA 1> $TMP_OUT 2> $TMP_ERR
	./scripts/processProject.sh $TMP_IN $TMP_OUT 2> $TMP_ERR
	echo "done processing project"
	pwd
	OUT_DATA=$(jq -c '.' $TMP_OUT)
	echo "OUT_DATA: $OUT_DATA"
	amqp-publish -r $OUT_Q -C "application/json" --url $BROKER_URL --ssl -b "$OUT_DATA"
	#ERR_DATA=$(jq -c '.' $TMP_OUT)
	#echo "ERR_DATA: $ERR_DATA"
	#amqp-publish -r $ERR_Q -C "application/json" --url $BROKER_URL --ssl -b $ERR_DATA
done


echo "Queue is empy, $NODE_NAME will exit"



