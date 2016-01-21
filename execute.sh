#!/bin/bash

echo "cloning git repo"
git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git target 

echo "entering repo"
cd target

echo "Checkout correct branch: ${BASE_BRANCH}"
git checkout ${BASE_BRANCH}

echo "run task"
ruby ../execute.rb