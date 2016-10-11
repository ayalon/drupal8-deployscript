# Drupal 8 Deployment Scripts

## Setting up aliases
Before you can use the deployment script, you need to set-up some alias in

```bash
drush/aliases.drushrc.php
```

## Drupal 8 Deployment script
This script deploys a Drupal 8 site to a remote host
```bash
deploy/dev-deploy.sh
```

## Copy dev environment to local
This script copies over the database and the fiels from a remote site using drush
```bash
deploy/copy-dev-to-self.sh
```


## Example composer.json file with a Drupal 8 installation
This file shows the usage of patches / remote or local patches