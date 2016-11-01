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
    chmod -R o+w storage
    chmod -R o+w bootstrap/cache
    composer install
    echo "REMEMBER: Setup your .env file and set application key"
  else
    # Updating git on previously deployed project (git reset)
    git remote remove origin
    git remote add origin deploy/repository
    cd deploy/repository
    git checkout $BRANCH -f
    cd ../..
    git fetch
    git checkout $BRANCH
    git branch --set-upstream-to=origin/$BRANCH $BRANCH
    git pull
  fi

  rm -rf deploy
EOF