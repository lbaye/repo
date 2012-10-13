Social Maps Service Layer
=========================

This is the service layer of SocialMaps.com. Please follow the below steps to install it on your machine:

1. Install composer:

    ```BASH
    $ curl -s http://getcomposer.org/installer | php
    ```

2. Install the vendor libraries by running composer:

    ```BASH
    $ php composer.phar install
    ```

3. Setup <APP-ROOT>/web/.htaccess, Set application environment. ie - "prod" for production mode:
    
    ```CONFIGURATION
    SetEnv APPLICATION_ENV prod

    <IfModule mod_rewrite.c>
      RewriteEngine On
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteRule ^(.*)$ index.php [QSA,L]
    </IfModule>
    ```

4. Setup a VirtualHost with the following configuration (modify as needed):
    
    ```CONFIGURATION
    <VirtualHost *:80>

        ServerName api.socialmaps.local
        DocumentRoot "/var/www/socialmaps/web"

        <Directory "/var/www/socialmaps/web">
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Allow from All
        </Directory>

    </VirtualHost>
    ```

5. Test the default controller using cURL:

    ```BASH
    $ curl http://api.socialmaps.local/hello
    ```
    
6. Setup background worker process:

    ```BASH
    $ nohup php <Project ROOT>/bin/worker.php
    ```

7. Enjoy!

8. After you've rejoiced a bit, run the following commands in your mongo shell to ensure indexing:

    ```javascript
    db.getCollection("deals").ensureIndex({"location":"2d"});
    db.getCollection("users").ensureIndex({"currentLocation":"2d"});
    db.getCollection("external_locations").ensureIndex({"coords":"2d"});
    db.getCollection("external_locations").ensureIndex({"refId":1, "source":1},{"unique": true});
    ```
9. Additional requirements:

    1. Change `AllowOverride` from `none` to `All`
    2. Enable `mod_rewrite`
    3. Enable `php extension curl`
    4. Enable `php extension mongo`

10. New deployment steps:
    
    1. Get code from git repository
    2. Set writable permission for <ROOT>/app
    3. Set writable permission for <ROOT>/web
    4. Run worker from bin/worker.php
    5. Run cron task from bin/cron.php


