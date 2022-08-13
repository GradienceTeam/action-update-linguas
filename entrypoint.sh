#!/bin/bash
set -e

# Set options based on user input
if [ -z "$INPUT_DESTINATION_PATH" ]; then
	DESTINATION_PATH="po"
else
	DESTINATION_PATH=$INPUT_DESTINATION_PATH
fi

if [ -z "$INPUT_PO_DIR" ]; then
	SLUG="po"
else
	SLUG=$INPUT_PO_DIR
fi

if [ -z "$PAT_TOKEN" ]; then
	TOKEN=$GITHUB_TOKEN
else
	TOKEN=$PAT_TOKEN
fi