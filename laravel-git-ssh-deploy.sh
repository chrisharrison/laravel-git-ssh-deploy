#!/bin/bash

# $BRANCH = 'master'
# $GIT_LOCATION = 'git@git-hosting.com:repository.git'
# $REMOTE_DOMAIN = 'my-server.com'
# $REMOTE_USERNAME = 'user'
# $REMOTE_DESTINATION = '/web/root/project'

# Clone current project to fresh git repository and tar it up
rm -rf deploy
mkdir deploy
git clone $GIT_LOCATION deploy/repository
tar -zcvf deploy/deploy.tar.gz deploy/repository

# Prepare remote folder
ssh $REMOTE_USERNAME@$REMOTE_DOMAIN << EOF
  mkdir -p $REMOTE_DESTINATION/deploy
EOF

# Upload tar to remote folder
scp deploy/deploy.tar.gz $REMOTE_USERNAME@$REMOTE_DOMAIN:$REMOTE_DESTINATION/deploy

rm -rf deploy

ssh $REMOTE_USERNAME@$REMOTE_DOMAIN << EOF

  # Untar remote
  cd $REMOTE_DESTINATION
  tar -xvzf deploy/deploy.tar.gz

  if [ ! -d .git ]
  then
    # Fresh installation (move repo files)
    mv deploy/repository/{.[!.],}* .
    git checkout $BRANCH
    composer install
    chmod -R o+w storage
    echo "REMEMBER: Setup your .env file and set application key"
  else
    # Updating git on previously deployed project (git pull)
    git remote set-url origin deploy/repository
    git branch --set-upstream-to=origin/$BRANCH
    git checkout $BRANCH
    git pull
  fi

  rm -rf deploy
EOF