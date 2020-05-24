#!/bin/bash

git status -s | cut -c4- | awk '{ if ($1 ~ /swift$/) print $1 }' | xargs swimat