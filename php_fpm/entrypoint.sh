#!/bin/sh
set -e

if [ -z "$(find /data -user "$(id -u)" -print -prune -o -prune)" ]; then
    echo "/data is not owned by the correct user, we are uid $(id -u)"
    exit 1
fi

if [ -n "$(ls -A /data 2>/dev/null)" ]
then
    echo "Data directory contains files, not downloading NamelessMC"

    if [ -n "$NAMELESS_COMPOSER_INSTALL" ]
    then
        echo "WARNING: NAMELESS_COMPOSER_INSTALL is deprecated, use NAMELESS_ALWAYS_INSTALL_DEPENDENCIES instead."
        echo "NAMELESS_COMPOSER_INSTALL set, running composer install..."
        composer install --no-progress --no-interaction
    fi

    if [ -n "$NAMELESS_ALWAYS_INSTALL_DEPENDENCIES" ]
    then
        echo "NAMELESS_ALWAYS_INSTALL_DEPENDENCIES set; running composer and yarn before starting webserver"
        echo "Running composer..."
        composer install --no-progress --no-interaction

        echo "Running yarn..."
        # When running yarnpkg after downloading, the script deletes node_modules. However, doing that here
        # would require redownloading all modules at every container start.
        # Someone setting NAMELESS_ALWAYS_INSTALL_DEPENDENCIES probably doesn't care about a bit of extra disk usage.
        yarnpkg
    fi
else
    echo "Data directory is empty, downloading NamelessMC..."
    set -x
    curl -L "https://github.com/NamelessMC/Nameless/archive/v2.tar.gz" | tar -xz --directory=/data -f -
    cd /data
    composer install --no-progress --no-interaction
    yarnpkg
    # Remove some unnecessary files
    rm -rf \
        .htaccess \
        cache/.htaccess \
        changelog.txt \
        CONTRIBUTORS.md \
        docker-compose.yaml \
        Dockerfile \
        nginx.example \
        README.md \
        web.config.example \
        uploads/placeholder.txt \
        LICENSE.txt \
        SECURITY.md \
        phpstan.neon \
        node_modules # generated by yarnpkg, but assets are copied to vendor directory
    chmod -R ugo-x,u+rwX,go-rw . # Files 600 directories 700
    set +x
    echo "Done!"
fi

if [ -n "$NAMELESS_AUTO_INSTALL" ]
then
    if [ -f core/config.php ]; then
        echo "core/config.php exists, not running installer."
    elif [ ! -f scripts/cli_install.php ]; then
        echo "CLI install script doesn't exist, not running installer."
    else
        echo "Going to run installer, first waiting 5 seconds for the database to start"
        sleep 5
        echo "Running installer..."
        php -f scripts/cli_install.php -- --iSwearIKnowWhatImDoing
    fi
fi

{ \
    echo "[www]"
    echo "pm = $PHP_PM"
    echo "pm.max_children = $PHP_PM_MAX_CHILDREN"
    echo "pm.max_requests = $PHP_PM_MAX_REQUESTS"
    echo "pm.process_idle_timeout = $PHP_PM_IDLE_TIMEOUT"
    echo "pm.start_servers = $PHP_PM_MIN_SPARE_SERVERS"
    echo "pm.min_spare_servers = $PHP_PM_MIN_SPARE_SERVERS"
    echo "pm.max_spare_servers = $PHP_PM_MAX_SPARE_SERVERS"
} > /tmp/additional-php-fpm-settings.conf # this file is symlinked to the correct php-fpm configuration dir

exec php-fpm
