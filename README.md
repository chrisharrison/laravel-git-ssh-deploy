# laravel-git-ssh-deploy

Deploy Laravel projects using Git and SSH.

## Overview

`laravel-git-ssh-deploy` is a shell script that will upload a Laravel project (held in a Git repository) to a destination server over SSH. It handles branches. It also runs `composer install` and `chmod` on the Laravel storage directory on fresh install.

## Why?

I was working on a project where Git repositories were stored on a private network within the company, but the destination server was on the public internet.

## Variables

* `$BRANCH` = The Git branch you want to deploy. e.g 'master'
* `$GIT_LOCATION` = The location of the hosted Git repository. e.g. 'git@git-hosting.com:repository.git'
* `$REMOTE_DOMAIN` = The domain of the server you want to deploy. to e.g. 'my-server.com'
* `$REMOTE_USERNAME` = The username of the remote server. e.g. 'user'
* `$REMOTE_DESTINATION` = The directory location on the remote server. e.g. '/web/root/project'