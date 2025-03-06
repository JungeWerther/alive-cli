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

# Decrypt credentials
GPG_TTY=$(tty)
export GPG_TTY
CREDENTIALS=$(gpg --decrypt $CREDENTIALS_ROOT)


# Export AWS credentials
eval "$CREDENTIALS"

# Run command with remaining args
shift
$@

# Clear environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION







# # Exit on any error
# set -e

# # Variables
# # Push to github
# echo "🔄 Pushing latest changes to GitHub..."
# git push

# # SSH into server and run commands
# # Optional: Replace with your own deployment logic
# echo "🚀 Deploying to server..."
# ssh $SERVER "cd $DEPLOY_DIR && \
#     git pull origin $BRANCH"

#     # DEBUG:
#     # && \
#     # mix deps.get && \
#     # mix compile && \
#     # mix phx.server restart"

# echo "✅ Deployment complete!"
