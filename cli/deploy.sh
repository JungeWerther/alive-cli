#!/bin/bash
# deploy.sh
#
# work in progress..
#
# Deploys the latest changes to the server
#
# Depends on:
#   - $SERVER
#   - $DEPLOY_DIR
#   - $BRANCH

# Exit on any error
set -e

# Variables
# Push to github
echo "🔄 Pushing latest changes to GitHub..."
git push

# SSH into server and run commands
# Optional: Replace with your own deployment logic
echo "🚀 Deploying to server..."
ssh $SERVER "cd $DEPLOY_DIR && \
    git pull origin $BRANCH"

    # DEBUG:
    # && \
    # mix deps.get && \
    # mix compile && \
    # mix phx.server restart"

echo "✅ Deployment complete!"
