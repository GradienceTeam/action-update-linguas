#!/bin/bash
set -e

# Set options based on user input
if [ -z "$INPUT_DESTINATION_PATH" ]; then
	DESTINATION_PATH="po"
else
	DESTINATION_PATH=$INPUT_DESTINATION_PATH
fi

if [ -z "$INPUT_PO_DIR" ]; then
	PO_DIR="po"
else
	PO_DIR=$INPUT_PO_DIR
fi

if [ -z "$PAT_TOKEN" ]; then
	TOKEN=$GITHUB_TOKEN
else
	TOKEN=$PAT_TOKEN
fi

# Setup Git config and push .pot file to github repo
git config --global user.name "AdwCustomizer"
git config --global user.email "AdwCustomizerTeam@proton.me"
git config --global --add safe.directory "$GITHUB_WORKSPACE"

REPO_NAME="$GITHUB_REPOSITORY"
if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
	FORK=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.repo.fork)
	MODIFY=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.maintainer_can_modify)
	if [ "$FORK" == true ]; then
		REPO_NAME=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.repo.full_name | cut -d "\"" -f 2)
		REMOTE=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.repo.clone_url | cut -d "\"" -f 2)
	else
		REMOTE="origin"
	fi

	if [ "$FORK" == true ] && [ "$MODIFY" == false ]; then
		echo "🚫 PR can't be modified by maintainer"
	fi

	echo "✔️ GITHUB_EVENT_PATH: $GITHUB_EVENT_PATH"
	echo "✔️ FORK: $FORK"
	echo "✔️ MODIFY : $MODIFY"
	echo "✔️ REMOTE: $REMOTE"
	echo "✔️ BRANCH: $GITHUB_HEAD_REF"

	# Checkout to PR branch
	git fetch "$REMOTE" "$GITHUB_HEAD_REF:$GITHUB_HEAD_REF"
	git config "branch.$GITHUB_HEAD_REF.remote" "$REMOTE"
	git config "branch.$GITHUB_HEAD_REF.merge" "refs/heads/$GITHUB_HEAD_REF"
	git checkout "$GITHUB_HEAD_REF"
fi

# Generate LINGUAS file.
echo "🔨 Generating LINGUAS file"

cd $PO_DIR
for f in *.po; do
  echo "${f%%.*}\n" >> /tmp/LINGUAS
done

cd $GITHUB_WORKSPACE

cat /tmp/LINGUAS

if [[ $(cat /tmp/LINGUAS) != $(cat "$DESTINATION_PATH/LINGUAS") ]]; then
  mv /tmp/LINGUAS "$DESTINATION_PATH/LINGUAS"
  
  
  # Push file to repository.
  if [ "$(git status $POT_PATH --porcelain)" != "" ]; then
     echo "🔼 Pushing to repository"
     git add "$POT_PATH"
     git commit -m "🔄 Generated POT File"
     if [ "$FORK" == true ]; then
	echo "debug: $REPO_NAME"
	git config credential.https://github.com/.helper "! f() { echo username=x-access-token; echo password=$TOKEN; };f"
	git push "https://x-access-token:$TOKEN@github.com/$REPO_NAME"
     else
	git push "https://x-access-token:$GITHUB_TOKEN@github.com/$REPO_NAME"
     fi	
  else
     echo "☑️ No changes are required to .pot file"
  fi
fi
