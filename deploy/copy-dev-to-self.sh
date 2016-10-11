#!/usr/bin/env bash

#execute on the dev system
echo "This script has to be executed on the target system"
echo "Drush defines the alias @self to refer to the currently bootstrapped site."

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "-----------------------------------------------------------"
echo "Switch directory to drupal web folder"
cd $DIR/../web
pwd

#copy over db
echo "copy over database"
drush sql-sync @dev @self

#rsync files folder
echo "Rsyncing files from live system"
drush rsync @dev:%files/ @self:%files

echo "Cache rebuild"
drush cr

echo "All done..."
