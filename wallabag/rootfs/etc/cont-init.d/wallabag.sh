#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Wallabag
# This file configures Wallabag
# ==============================================================================

bashio::log.info "Setting required env vars"

export DATABASE_DRIVER=pdo_mysql
export DATABASE_PATH=null
export DATABASE_HOST
export DATABASE_PORT
export DATABASE_NAME
export DATABASE_USER
export DATABASE_PASSWORD
export DOMAIN_NAME='http://localhost:8000'
export SERVER_NAME='Wallabag instance'
export TOKEN_SECRET
export APP_LOCALE=en
export TWOFACTOR_AUTH=false
export TWOFACTOR_SENDER='no-reply@wallabag.org'
export FROM_EMAIL='no-reply@wallabag.org'
export ANYONE_CAN_REGISTER=false
export FOS_USER_CONFIRMATION=false

#Create assets folder
if ! bashio::fs.directory_exists "/data/wallabag/assets"; then
    bashio::log "Creating assets directory"
    mkdir -p /data/wallabag/assets/images
    chown www-data:www-data /data/wallabag/assets
fi

rm -r /var/www/wallabag/web/assets
ln -s /data/wallabag/assets /var/www/wallabag/web/assets

#Create data folder
if ! bashio::fs.directory_exists "/data/wallabag/data"; then
    bashio::log "Creating data directory"
    mkdir -p /data/wallabag/data/db
    chown www-data:www-data /data/wallabag/data
fi

rm -r /var/www/wallabag/data
ln -s /data/wallabag/data /var/www/wallabag/data

#Create cache folder
if ! bashio::fs.directory_exists "/data/wallabag/.cache"; then
    bashio::log "Creating data directory"
    mkdir -p /data/wallabag/.cache
    chown www-data:www-data /data/wallabag/.cache
fi

#if ! bashio::fs.directory_exists "/var/www/.cache"; then
#    rm -r /var/www/.cache
#fi

ln -s /data/wallabag/.cache /var/www/.cache

# Database setup
if bashio::config.has_value 'remote_mysql_host'; then
  if ! bashio::config.has_value 'remote_mysql_database'; then
    bashio::exit.nok \
      "Remote database has been specified but no database is configured"
  fi

  if ! bashio::config.has_value 'remote_mysql_username'; then
    bashio::exit.nok \
      "Remote database has been specified but no username is configured"
  fi

  if ! bashio::config.has_value 'remote_mysql_password'; then
    bashio::log.fatal \
      "Remote database has been specified but no password is configured"
  fi

  if ! bashio::config.exists 'remote_mysql_port'; then
    bashio::exit.nok \
      "Remote database has been specified but no port is configured"
  fi
  # Set env vars
  DATABASE_HOST=$(bashio::config "remote_mysql_host")
  DATABASE_NAME=$(bashio::config "remote_mysql_database")
  DATABASE_USER=$(bashio::config "remote_mysql_username")
  DATABASE_PASSWORD=$(bashio::config "remote_mysql_password")
  DATABASE_PORT=$(bashio::config "remote_mysql_port")
else
  if ! bashio::services.available 'mysql'; then
     bashio::log.fatal \
       "Local database access should be provided by the MariaDB addon"
     bashio::exit.nok \
       "Please ensure it is installed and started"
  fi

  bashio::log.warning "Wallabag is using the Maria DB addon"
  bashio::log.warning "Please ensure this is included in your backups"
  bashio::log.warning "Uninstalling the MariaDB addon will remove any data"

  #setup env vars
  DATABASE_HOST=$(bashio::services "mysql" "host")
  DATABASE_NAME=wallabag
  DATABASE_USER=$(bashio::services "mysql" "username")
  DATABASE_PASSWORD=$(bashio::services "mysql" "password")
  DATABASE_PORT=$(bashio::services "mysql" "port")

  bashio::log.info "Creating database for Wallabag required"
  mysql \
    -u "${DATABASE_USER}" -p"${DATABASE_PASSWORD}" \
    -h "${DATABASE_HOST}" -P "${DATABASE_PORT}" \
    -e "CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\` ;"
fi

bashio::log.info "Setting up remainig Wallabag env vars"

# Set remaining env vars
if bashio::config.has_value 'tokens_secret';then
    TOKEN_SECRET=$(bashio::config "tokens_secret")
else
    #TODO auto generate secret
    TOKEN_SECRET="dc91c5e2255f441196c8c2bfa"
fi

if bashio::config.has_value 'locale';then
    APP_LOCALE=$(bashio::config "locale")
fi

if bashio::config.has_value 'app_url';then
    DOMAIN_NAME=$(bashio::config "app_url")
fi

if bashio::config.has_value 'app_name';then
    SERVER_NAME=$(bashio::config "app_name")
fi

# Two factor config
if bashio::config.has_value 'twofactor_auth';then
    TWOFACTOR_AUTH=$(bashio::config "twofactor_auth")
fi

if bashio::config.has_value 'twofactor_sender';then
    TWOFACTOR_SENDER=$(bashio::config "twofactor_sender")
fi

# User registration options
if bashio::config.has_value 'anyone_can_register';then
    ANYONE_CAN_REGISTER=$(bashio::config "anyone_can_register")
fi

if bashio::config.has_value 'fosuser_confirmation';then
    FOS_USER_CONFIRMATION=$(bashio::config "fosuser_confirmation")
fi

bashio::log.info "Setting up parameters.yml"
# Set parameters.yml
if bashio::fs.file_exists "/opt/wallabag/config/parameters.yml"; then
    bashio::log "setting up parameters.yml file"
    rm -f /var/www/wallabag/app/config/parameters.yml
    envsubst < /opt/wallabag/config/parameters.yml > /var/www/wallabag/app/config/parameters.yml
    #cat /var/www/wallabag/app/config/parameters.yml
else
    bashio::exit.nok \
      "Parameters file not found in /opt/wallabag/config/parameters.yml"
fi

bashio::log.info "Runnning Wallabag install script"

php /var/www/wallabag/bin/console wallabag:install --env=prod --no-interaction

bashio::log.info "correcting owner settings on app folders"
chown -R www-data:www-data /var/www/wallabag/app
chown -R www-data:www-data /var/www/wallabag/var
