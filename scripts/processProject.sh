#!/bin/bash

#IN_JSON=$(cat scripts/in.json)
IN_JSON=$1
OUT_JSON=$2

echo "[process project] $IN_JSON -> $OUT_JSON"

WORKDIR="tmp"
ROOTDIR=$(pwd)
LOGDIR="$ROOTDIR/log"


#clean workdir
if [ -d "$WORKDIR" ]; then rm -Rf $WORKDIR; fi
if [ -d "$LOGDIR" ]; then rm -Rf $LOGDIR; fi

GA=$(cat $IN_JSON | jq .ga | sed 's/"//g')
REPO=$(cat $IN_JSON | jq .repo | sed 's/"//g')
DATASET=$(cat $IN_JSON | jq .dataset | sed 's/"//g')
mkdir $LOGDIR

echo $GA $REPO

CLONE="NA"
CLOC="[]"
LAST_COMMIT_DATE="NA"
NB_COMMITS="NA"
NB_BRANCHES="NA"
NB_TAGS="NA"
NB_COMMITTERS="NA"
ID_COMMIT="NA"
COMPILE="NA"
TEST1="NA"
NB_TESTS="NA"
TEST2="NA"
POM="NA"

echo "[process project] pre clone: git clone $REPO $WORKDIR"
GIT_TERMINAL_PROMPT=0 git clone $REPO $WORKDIR
if [ $? -eq 0 ]; then
	CLONE=$(echo "true")
	echo "[process project] cloned"

	cd $WORKDIR
	WD=$(pwd)
	echo "[process project] $WD"

	#nb commit
	NB_COMMITS=$(git rev-list --all --count)
	#nb branches
	NB_BRANCHES=$(git branch | wc -l)
	#nb tags
	NB_TAGS=$(git tag | wc -l)

	#nb committers
	NB_COMMITTERS=$(git shortlog -sne --all | wc -l)
	# is multimodule

	git log -1 --format=%cd > $LOGDIR/pdate.log
	LAST_COMMIT_DATE=$(cat $LOGDIR/pdate.log)

	git reset --hard $(git tag | tail -1)

	#get current commit
	ID_COMMIT=$(git rev-parse HEAD)

	#lines of code for each language
	cloc . --csv --out $LOGDIR/cloc-report.csv
	tail -n +2 $LOGDIR/cloc-report.csv | sed 's/^/{\"files": /' | sed 's/,/, "lang": "/' | sed 's/,/", "blank": /2'  | sed 's/,/, "comment": /3' | sed 's/,/, "code": /4' | sed 's/$/}/' | paste -sd "," - > $LOGDIR/cloc-report.json
	TOTO=$(cat $LOGDIR/cloc-report.json)
	CLOC=$(echo "[$TOTO]" | jq .)

	echo "[process project] stat ok"

	#is there a pom at the root
	if [ -f pom.xml ]; then
		POM=$(echo "true")

		#compile
		mvn compile > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			COMPILE=$(echo "true")
			#test
			mvn test -Dsurefire.skipAfterFailureCount=1 > $LOGDIR/test.log 2>&1
			if [ $? -eq 0 ]; then
				TEST1=$(echo "true")

				NB_TESTS=$(grep "Tests run: " $LOGDIR/test.log | cut -d ',' -f1 | cut -d ' ' -f3 | paste -sd+ | bc)
				NB_TESTS=$((NB_TESTS / 2))
				#test
				mvn test -Dsurefire.skipAfterFailureCount=1 > /dev/null 2>&1
				if [ $? -eq 0 ]; then
					TEST2=$(echo "true")
				else
					TEST2=$(echo "false")
				fi

			else
				TEST1=$(echo "false")
			fi
			echo "TEST1: $TEST1, NB_TESTS: $NB_TESTS, TEST2: $TEST2"
		else
			COMPILE=$(echo "false")
		fi

	else
		POM=$(echo "false")
	fi
	pwd
	echo "[process project] exit workdir"
	cd $ROOTDIR
	pwd
	echo "[process project] exited"
else
	CLONE=$(echo "false")
fi

pwd
echo "{ \"ga\": \"$GA\", \"repo\": \"$REPO\", \"dataset\": \"$DATASET\", \"clone\": \"$CLONE\", \"lastCommitDate\":\"$LAST_COMMIT_DATE\", \"nbCommits\": \"$NB_COMMITS\", \"nbBranches\": \"$NB_BRANCHES\", \"nbTags\": \"$NB_TAGS\", \"nbCommitters\": \"$NB_COMMITTERS\", \"idCommit\": \"$ID_COMMIT\", \"cloc\": $CLOC, \"rootPOM\": \"$POM\", \"compile\": \"$COMPILE\", \"test1\": \"$TEST1\", \"nbTests\": \"$NB_TESTS\", \"test2\": \"$TEST2\"}" | sed 's/ //g' | jq . > $OUT_JSON


echo "[process project] done"
