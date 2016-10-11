#!/usr/bin/env bash

usage() {
cat << EOF
usage: $0 options

This script deploys shkb to the dev system

OPTIONS:
   -h      Show this message
   -s      Restart solr
   -i      Reindex all content on solr
   -r      Rsync all file instead of using git diff
EOF
}

solr=0
index=0
rsync=0
while getopts "hsi" OPTION;do
   case $OPTION in
       h)
           usage
           exit 1
           ;;
       s)
           solr=1
           ;;
       r)
           rsync=1
           ;;
       i)
           index=1
           ;;
       ?)
           usage
           exit
           ;;
   esac
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "-----------------------------------------------------------"
echo "Switch directory to drupal web folder"
cd $DIR/../web
pwd

if [ $rsync -eq 1 ];then
  #rsync all files
  echo "Rsyncing all files except those listed in deploy/exclude-file.txt + .gitignore"
  echo "-----------------------------------------------------------"
  drush -v -y rsync @local @dev
else
  #upload a git delta of the file
  echo "Using git to checkout lastest master on target server"
  echo "-----------------------------------------------------------"
  drush @dev ssh git fetch
  drush @dev ssh git checkout master
  drush @dev ssh git pull
fi

# install composer dependancies
# IMPORTANT: composer will not be picked up on managed server because bashrc is being skipped
# To fix that, uncomment the interactive check in .bashrc
# --------------------------------
# If not running interactively, don't do anything
# [ -z "$PS1" ] && return <--- this line!!
echo "-----------------------------------------------------------"
echo "Running composer install"
drush @dev ssh "cd  .. && composer install"

#deploy the solr configuration
echo "-----------------------------------------------------------"
echo "Deploying solr config files"
drush @dev ssh rsync -az ../solr/search-api_conf/ /home/www-data/solr/solr-6/server/solr/asvz_searchapi_dev/conf

#restart solr
if [ $solr -eq 1 ];then
  echo "-----------------------------------------------------------"
  echo "Restarting solr instance"
  drush @dev ssh /home/www-data/solr/solr-6/bin/solr restart
fi

#clear redis cache
echo "-----------------------------------------------------------"
echo "Flushing redis cache...."
drush @dev ssh redis-cli FLUSHALL

echo "-----------------------------------------------------------"
echo "Database updates"
drush @dev updb
drush @dev entity-updates

#execute some drush commands
echo "-----------------------------------------------------------"
echo "Importing configuration"
drush @dev config-import -y

echo "-----------------------------------------------------------"
echo "Clearing cache"
drush @dev cr

#reindex all content
if [ $solr -eq 1 ];then
echo "-----------------------------------------------------------"
echo "reindex all content"
drush @dev solr-mark-all
drush @dev solr-index
drush @dev search-reindex -y
drush @dev search-index
fi

echo "All done..."

