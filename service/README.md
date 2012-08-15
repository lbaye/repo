Social Maps Service Layer
=========================

This is the service layer of SocialMaps.com. Please follow the below steps to install it on your machine:

1. Install composer:

    curl -s http://getcomposer.org/installer | php

2. Install the vendor libraries by running composer:

    php composer.phar install

3. Setup a VirtualHost with the following configuration (modify as needed):

    <VirtualHost *:80>

        ServerName api.socialmaps.local
        DocumentRoot "/var/www/socialmaps/web"

        <Directory "/var/www/socialmaps/web">
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Allow from All
        </Directory>

    </VirtualHost>

4. Test the default controller using cURL:

    curl http://api.socialmaps.local/hello

5. Enjoy!

6. After you've rejoiced a bit, run the following commands in your mongo shell to ensure indexing:

    db.getCollection("deals").ensureIndex({"location":"2d"});
    db.getCollection("users").ensureIndex({"currentLocation":"2d"});
    db.getCollection("external_locations").ensureIndex({"coords":"2d"});
    db.getCollection("external_locations").ensureIndex({"refId":1, "source":1},{"unique": true});
