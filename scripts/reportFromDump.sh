#!/bin/bash


# Read from Q

CONFIG_FILE="./config.json"

BROKER_URL=$(cat $CONFIG_FILE | jq -r '.broker')
NODE_NAME=$(cat $CONFIG_FILE | jq -r '.node')
IN_Q=$(cat $CONFIG_FILE | jq -r '.inq')
OUT_Q=$(cat $CONFIG_FILE | jq -r '.outq')
ERR_Q=$(cat $CONFIG_FILE | jq -r '.errq')

PROJECT_OUTPUT="projects.csv"
PROJECT_HEADER=""
LANGUAGE_OUTPUT="languages.csv"
LANGUAGE_HEADER=""

SAVE_DIR="save"
if [ ! -d "$SAVE_DIR" ]; then mkdir $SAVE_DIR; fi

#while IFS="" read -r p || [ -n "$DATA" ]
cat $SAVE_DIR/save.json.dump | while read DATA 
do
	#echo "data: $DATA"
	#echo $DATA >> $SAVE_DIR/save.json.dump
	GROUPID=$(echo $DATA | jq -r '.ga' | cut -d ':' -f1)
	ARTIFACTID=$(echo $DATA | jq -r '.ga' | cut -d ':' -f2)
	REPO=$(echo $DATA | jq -r '.repo')
	dataset=$(echo $DATA | jq -r '.dataset')
	clone=$(echo $DATA | jq -r '.clone')
	lastCommitDate=$(echo $DATA | jq -r '.lastCommitDate')
	nbCommits=$(echo $DATA | jq -r '.nbCommits')
	nbBranches=$(echo $DATA | jq -r '.nbBranches')
	nbTags=$(echo $DATA | jq -r '.nbTags')
	nbCommitters=$(echo $DATA | jq -r '.nbCommitters')
	idCommit=$(echo $DATA | jq -r '.idCommit')
	rootPOM=$(echo $DATA | jq -r '.rootPOM')
	compile=$(echo $DATA | jq -r '.compile')
	test1=$(echo $DATA | jq -r '.test1')
	nbTests=$(echo $DATA | jq -r '.nbTests')
	if [ -z "$nbTests" ]
	then
		nbTests="0"
	fi
	test2=$(echo $DATA | jq -r '.test2')
	echo "$GROUPID, $ARTIFACTID, $REPO, $dataset, $clone, $lastCommitDate, $nbCommits, $nbBranches, $nbTags, $nbCommitters, $idCommit, $rootPOM, $compile, $test1, $nbTests, $test2" >> $PROJECT_OUTPUT


	for line in $(echo $DATA | jq -c '.cloc | .[]')
	do

	  files=$(echo $line | jq -r '.files')
	  lang=$(echo $line | jq -r '.lang')
	  blank=$(echo $line | jq -r '.blank')
	  comment=$(echo $line | jq -r '.comment')
	  code=$(echo $line | jq -r '.code')

	echo "$GROUPID, $ARTIFACTID, $files, $lang, $blank, $comment, $code" >> $LANGUAGE_OUTPUT
	done
done
#done < $SAVE_DIR/save.json.dump
