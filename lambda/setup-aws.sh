#!/bin/bash

# Step 1: Install Node:
# Go to: https://nodejs.org/en/download/package-manager/

# Step 2: Install serverless
npm install -g serverless

# Step 3: Setup serverless
serverless config credentials --provider aws --key XXX --secret YYY --profile serverless-admin
