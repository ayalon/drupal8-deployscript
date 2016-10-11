<?php
$homedir = getenv('HOME');

$aliases['dev'] = array(
  'root' => '/home/www-data/dev.folder/web',
  'uri' => 'www.hostname.remote',
  'remote-host' => 'www.hostname.remote',
  'remote-user' => 'www-data',
  'path-aliases' => array(
    '%drush-script' => '/home/www-data/bin/drush',
    '%composer' => '/home/www-data/bin/composer',
  ),
);